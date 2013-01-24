<?php

/*
 * This file is part of the NeatReports package.
 * (c) 2011-2012 Juan Manuel Fernandez <juanmf@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */
namespace Juanmf\NeatReports\RenderStep2;

/**
 * This is a Factory that constructs the CompositeView Tree of the Report, 
 * it could consist either in a single node or in a tree of any complexity.
 * 
 * This Tree is responsible for rendering the XSL-FO of the report, i.e. the 
 * intermediate stage of the report in the report generatin process, which consist 
 * in three steps, so it can be rendered from its standard XSL-FO format to any 
 * suppoorted outpt format in step3, e.g. PDF or HTML.
 *
 * @author Juan Manuel Fernandez <juanmf@gmail.com>
 * @see    BasicView, %sf_app_module_dir%/export/config/sfExportConfig.yml
 */
class CompositeFactory
{
    protected static $_defView;
    protected static $_defCompositeView;
    protected static $_xPath = null;

    /**
     * The module dir used as a prefix for all configuration relative paths.
     * @var string
     */
    protected static $_appDir;
    
    /**
     * Reads config about the curren report about to be rendered in order to split
     * the LogocalScreen (or RawXMLData), instantiate all the BasicView nodes in
     * the CompositeView Tree, in case the report has Tree structure, and assign
     * to each its own LogicalScreen portion, enabling each BasicView object to
     * populate its XSLFO template with the given data.
     * 
     * @param array       $config        The Report Config array from sfExportConfig.yml
     * @param DomDocument $logicalScreen With the whole data, we partition it
     * accodring to config's step2 structure.
     * 
     * @return BasicView The root node of the Composite.
     * @see    %sf_plugins_dir%/NeatReports/config/sfExportConfig.yml
     */
    public static function getComposite(array $config, DomDocument $logicalScreen)
    {
        $globalConf = sfConfig::get('mod_export_globals');
        self::$_appDir = sfConfig::get('sf_app_dir');
        self::$_defView = $globalConf['step2']['structure_class']['leaf'];
        self::$_defCompositeView = $globalConf['step2']['structure_class']['parent']; 
        
        self::splitDom($config['step2']['layout'], $logicalScreen);
        
        /**
         * Now I have a new Dom (representing logicalViewBranch) in each "nodes"
         * key in $config['step2']['layout']. Assign each to a new BasicView with
         * the sructure suggested by $config['step2']['layout']
         */
        return self::makeCompositeView($config['step2']['layout']);
    }
    
    /**
     * Recursivelly iterates the $config['step2']['layout'] instantiating a
     * BasicView for each node, assigning to it structure, style, and logical
     * data that each one is responsible to render.
     * 
     * @param array &$structure A branch of the report structure tree. The root being
     * $config['step2']['layout'].
     * 
     * @return BasicView with the root of the report branch that $structure
     * represents
     */
    protected static function makeCompositeView(array &$structure) 
    {
        $class = $structure['class'];
        $logicalViewBranch = $structure['nodes'];
        $xsltStructure = (null !== $structure['xslt_structure']['sheet']) 
                       ? self::$_appDir 
                       . $structure['xslt_structure']['sheet']
                       : null;
        $xsltStructureParams = $structure['xslt_structure']['params'];
        $xsltStyle = (null !== $structure['xslt_style']['sheet'])
                   ? self::$_appDir 
                   . $structure['xslt_style']['sheet']
                   : null;
        $xsltStyleParams = $structure['xslt_style']['params'];
        $hasChilds = ! empty($structure['children']);
        if ($hasChilds) {
            $view = (null === $class) ? new self::$_defCompositeView() : new $class();
            foreach ($structure['children'] as $name => $child) {
                $view->addView($name, self::makeCompositeView($child));
            }
        } else {
            $view = (null === $class) ? new self::$_defView() : new $class();
        }
        /* @var $view BasicView */
        $view->setLogicalView($logicalViewBranch);
        $view->setStructure($xsltStructure);
        $view->setStructureParams($xsltStructureParams);
        $view->setStyle($xsltStyle);
        $view->setStyleParams($xsltStyleParams);
        return $view;
    }
    
    /**
     * Traverses the report structure array, pruning the logicalScreen XML tree,
     * putting a new DOMDocument containing the selectedd nodes in the place 
     * where the original xpath query was in the config layout array, i.e. the 
     * 'nodes' keys.
     * 
     * Note that descendant nodes of nodes selected by a xPath query which are
     * selected by the xPapth query of another report structure node are
     * removed from the first DOM tree.
     * 
     * @param array       &$layout       The $config['step2']['layout'] with report strcucture.
     * @param DOMDocument $logicalScreen The prepared XML with data for this report.
     * 
     * @return void
     * @see    %sf_plugins_dir%/NeatReports/config/sfExportConfig.yml
     */
    protected static function splitDom(array &$layout, DOMDocument $logicalScreen)
    {
        $allViewsQueriedNodes = new ArrayObject(array());
        self::setXpathDom($logicalScreen);
        array_walk_recursive(
            $layout, array('CompositeFactory', '_replaceNodesKeys'), $allViewsQueriedNodes
        );
        foreach ($allViewsQueriedNodes as $k => &$viewQueriedNodes) {
            $dom = self::createViewLogicalScreenDomDocument();
            $documentElement = $dom->documentElement;
            foreach ($viewQueriedNodes as $node) {
                $newNode = $dom->importNode($node, true);
                $documentElement->appendChild($newNode);
            }
            $foreignNodeList = self::$_xPath->query(
                '/root/*//*[@search_me_im_a_view_root_node]'
            );
            
            foreach ($foreignNodeList as $node) {
                $node->parentNode->removeChild($node);
            }
            /* Replacing DomNodeLists for correspondin new DOM in 
             * $config['step2']['layout'][//]['nodes']. Where previouly we had
             * the xpath expressions that where replaced by its result DomNodeLists.
             * Remember that now $nodesDomNodeLists is a flat array pointing to every
             * 'nodes' value in $config['step2']['layout'].
             */
            $viewQueriedNodes = $dom;
        }
    }
    
    /**
     * Convenience method to create each BasicView's LogicalScreen DomDocument, 
     * so we can later add data nodes to it, enablig the XSLT teemplate to populate 
     * the XSL-FO template of the report.
     * 
     * @return DOMDocument 
     */
    public static function createViewLogicalScreenDomDocument()
    {
        $dom = new DOMDocument();
        $dom->appendChild($dom->createElement('root'));
        self::setXpathDom($dom);
        return $dom;
    }

    /**
     * Convenience callback that replaces the xPath expression of a report structure
     * node in the report structure config array, with the DOMNodeList that this expression
     * generates from the logicalScreen.
     * This is intended to be called from array_walk_recursive.
     * 
     * @param string &$xPathQuery          An XPATH expression
     * @param string $key                  A structure tree array key.
     * @param array  $allViewsQueriedNodes With $logicalScreen and $nodesDomNodeLists. 
     * The last being a reference used to populate a flat array pointing to every 
     * non empty "node" key in the structure array, making it easyer to access 
     * resulting DomNodeLists.
     * 
     * @return void
     */
    private static function _replaceNodesKeys(&$xPathQuery, $key, $allViewsQueriedNodes)
    {
        if ('nodes' === $key && ! empty($xPathQuery)) {
            $domList = self::$_xPath->query($xPathQuery);
            $xPathQuery = new ArrayObject(array());
            foreach ($domList as $domNode) {
                $domNode->setAttribute('search_me_im_a_view_root_node', 1);
                $xPathQuery[] = $domNode;
            }
            $allViewsQueriedNodes[] = $xPathQuery;
        } 
    }

    /**
     * Asociates this Class's XPath delegate to the given XML Document.
     * 
     * @param DOMDocument $dom A DomDocument object to query to.
     * 
     * @return void.
     */
    public static function setXpathDom(DOMDocument $dom)
    {
        self::$_xPath = new DOMXPath($dom);
    }
}
