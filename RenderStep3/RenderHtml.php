<?php

/*
 * This file is part of the NeatReports package.
 * (c) 2011-2012 Juan Manuel Fernandez <juanmf@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */
namespace Juanmf\NeatReports\RenderStep3;

/**
 * This class uses a XSLT Stylesheet to transform XSLFO to HTML. you can edit it
 * or use another one, the default one is fo2html.xsl
 * //TODO: add descriptoin of siup: namespace tags.
 * 
 * @author Juan Manuel Fernandez <juanmf@gmail.com>
 * @see    %sf_plugins_dir%/NeatReports/config/sfExportGlobals.yml
 * @see    Renderer
 * @see    %sf_plugins_dir%/NeatReports/lib/RenderStep3/xsl/fo2html.xsl
 */
class RenderHtml extends Renderer
{
    /**
     * Holds a ref to the xslt that converts a FO into a HTML tree.
     * @var SimpleXMLElement
     */
    protected $_toHtml = null;

    /**
     * Sets the FO o HTML transformation StyleSheet. It gets it from the config 
     * file sfExportGlobals.yml in: 
     * step3: {HTML: {xslt_output: sheet: ~}}.
     * 
     * @see    %sf_plugins_dir%/NeatReports/config/sfExportGlobals.yml
     */
    public function __construct()
    {
        parent::__construct();
        $toHtml = $this->_conf['step3']['HTML']['xslt_output']['sheet'];
        $toHtml && $this->_toHtml = simplexml_load_file($this->_pluginDir . $toHtml);
        $this->_structure = $this->_toHtml;
    }
}
