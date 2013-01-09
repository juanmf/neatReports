<?php

/*
 * This file is part of the reportPlugin package.
 * (c) 2011-2012 Juan Manuel Fernandez <juanmf@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/**
 * This class is meant to describe the implementation of the third Step in a three
 * steps process.
 * 
 * The process consists of the following steps:
 * <ol> 
 * <li>Step 1 consists in generating the XML bsaed raw data for the report. <b>RawXMLData</b></li>
 * <li>Step 2 consists in merging this raw data with a XSL-FO template to give it
 * the presentation information. XSL-FO acts as an intermediate language used 
 * to render the final repor in any format with a last transformation. <b>XSL-FO</b></li>
 * <li>Step 3 consists on rendering the XSL-FO representtion (the intermediate 
 * language) of the report to the desired output fromat. <b>FinalReport</b></li>
 * </ol>
 * 
 * Each output Format should be implemented by a class extending this one, and 
 * overriding Renderer::renderReport()
 * You can determine the class to use for each supported output format in the 
 * globals config file (config/sfExportGlobals.yml). Do this in the <i>class</i> 
 * key of every  Step3's output format description.
 * 
 * @author Juan Manuel Fernandez <juanmf@gmail.com>
 * @see    Renderer::renderReport()
 * @see    %sf_plugins_dir%/reportPlugin/config/sfExportGlobals.yml
 */
abstract class Renderer extends BasicView
{
    /**
     * Holds a ref to the xslt that converts a FO into a different FO tree.
     * @var SimpleXMLElement
     */
    protected $_toFo = null;
    
    /**
     * Holds the path to this application's reportPlugin dir
     * @var string
     */
    protected $_pluginDir = null;
    
    /**
     * Holds the Global configurations Array.
     * @see    %sf_plugins_dir%/reportPlugin/config/sfExportGlobals.yml
     * @var type 
     */
    protected $_conf = null;

    /**
     * Configures This class. Sets Modules Dir and config Array used by descendants.
     */
    public function __construct()
    {
        parent::__construct();
        $this->_pluginDir = sfConfig::get('sf_plugins_dir') . '/reportPlugin';
        $this->_conf = sfConfig::get('mod_export_globals');
    }
    
    /**
     * Instantiates the right Renderer According to user needs and config values
     * each suported output format should have its own Renerer child class 
     * implementing the render() method.
     * 
     * @param array $config the config array
     * 
     * @return Renderer An implementation of this Abstract class that should suit
     * the needs for the desired rendering for this report.
     * @see %sf_plugins_dir%/reportPlugin/config/sfExportGlobals.yml
     */
    public static function getInstance(array $config)
    {
        $outputFotmat = $config['step3']['output_format'];
        $rendererClass = $config['step3'][$outputFotmat]['class'];
        return $renderer = new $rendererClass();
    }
    
    /**
     * Alias for BasicView::setLogicalView().
     * As the final rendering of this report might involve just an other XSLT 
     * transformation, say you need to pass from XSL-FO to HTML, this class 
     * recicles, basicView rendering features. I which case the XSL-FO representation
     * of the report should be treated as a LogicalView (so BsicView thinks its
     * the raw XML we need to decorate) for a further decoraion/transformation 
     * process.
     * So in such cases the process ends u being:
     * <ol>
     * <li>Create RawXMLData (maybe with Doctrine XML Hydrator)</li>
     * <li>XSLT(RawXMLData) => XSL-FO</li> 
     * <li>XSLT(XSL-FO) => FinalReport, say HTML.</li>
     * </ol>
     * 
     * @param DOMDocument|String $xslFo The XSL-FO representation of this report,
     * as we get it from step 2.  
     * 
     * @see BasicView::setLogicalView()
     * @see %sf_plugins_dir%/reportPlugin/config/sfExportGlobals.yml
     * @return void.
     */    
    public function setReportFo($xslFo)
    {
        $this->setLogicalView($xslFo);
    }

    /**
     * Empty method. As Render inherits from Abstract BasicView but doesn't use 
     * all its Interface.
     * 
     * @param string    $name the Child view's name.
     * @param BasicView $view the Child view object.
     * 
     * @return void.
     */
    public function addView($name, BasicView $view)
    {
    }

    /**
     * Empty method. As Render inherits from Abstract BasicView but doesn't use 
     * all its Interface.
     * 
     * @param string $name the Child view's name.
     * 
     * @return void.
     */
    public function getChildView($name)
    {
    }

    /**
     * Empty method. As Render inherits from Abstract BasicView but doesn't use 
     * all its Interface.
     * 
     * @param string $name the Child view's name.
     * 
     * @return void.
     */
    public function removeView($name)
    {
    }

    /**
     * This is the final Step in this 3 steps process:
     * <ol> 
     * <li>Step 1 consists in generating the XML bsaed raw data for the report. </li>
     * <li>Step 2 consists in merging this raw data with a XSL-FO template to give it
     * the presentation information. XSL-FO acts as an intermediate language used 
     * to render the final repor in any format with a last transformation. </li>
     * <li>Step 3 consists on rendering the XSL-FO representtion (the intermediate 
     * language) of the report to the desired output fromat.</li>
     * </ol>
     * Here I implement tha basic behaviour, assuming we need only a last XSLT 
     * transformation, and reusing BasicView::render() for that. The XSLT that 
     * renders the XSL-FO representation should be set in the contructor.
     * 
     * @param DOMDocument   $xslFo    The XSL-FO representation of the processed 
     * report, as we get it just after step 2 in this 3 steps process.
     * @param sfWebResponse $response The Response Object, should be passed all 
     * the way down from the action. So we can change some headers, i.e. ContentType
     * 
     * @see %sf_plugins_dir%/reportPlugin/config/sfExportGlobals.yml
     * @return String With the rendered report content. Might be plain text or 
     * binary data.
     */
    public function renderReport(DOMDocument $xslFo, sfWebResponse $response = null) 
    {
        $this->setReportFo($xslFo);
        return parent::render()->saveXML();
    }
}
