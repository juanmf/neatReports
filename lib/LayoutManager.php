<?php

/*
 * This file is part of the reportPlugin package.
 * (c) 2011-2012 Juan Manuel Fernandez <juanmf@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/**
 * This class manages the entire report generation process. Passing controll to
 * the corresponding objects in each report generation Step.
 * 
 * @author Juan Manuel Fernandez <juanmf@gmail.com>
 * @see    LogicalScreenCallbacks, BasicView, Renderer, LayoutManager::render()
 */
class LayoutManager
{
    /**
     * Holds a reference to the root BasicView representing a rendering report.
     * @var BasicView
     */
    protected $_basicView = null;

    private static $_instance = null;

    private $_defCompositeView = null;

    private $_defView = null;

    /**
     * Instantiate the singleton
     */
    private function __construct()
    {
    }

    /**
     * Get the singleton
     * 
     * @return LayoutManager
     */
    public static function getInstance()
    {
        if (null === self::$_instance) {
            self::$_instance = new LayoutManager();
            return self::$_instance;
        }
        return self::$_instance;
    }

    /**
     * <pre>
     * implementes the three steps to render a report.
     * . 1) Call the user callback that returns logicalScreen, a XML with all the
     * .   data required by the report.
     * . 2) Splits logicalScreen according to report structure and inanstantiate
     * .   the compositeView structure of this report, asigning to each view:
     * .    a) Its portions of data in a DOMDocument. (optained from logicalScreen
     * .       with xPath queries)
     * .    b) Its structural XSLT capable of transformin (a) into the structure
     * .       of a portion of this report (as a Formated Object -FO- sheet).
     * .    c) Its style XSLT capable of adding style to this portion of the
     * .       report, that is, to the FO generated in (b).
     * .    Then render the whole tree generating the FO describing the entire
     * .     report in a botton-up recursive fashion.
     * . 3) Process the rendered FO translating it in any possible output format.
     * .    This task is delegated to a Renderer object.
     * .If XSLT are made with care, and the report decomposed coherently. They
     * .could be reused in similar reports.
     * </pre>
     * 
     * @param array         $config        The configuration Array from sfExportConfig.yml
     * @param sfWebResponse $response      The Response object provided by the action
     * @param DomDocument   $logicalScreen Optional. A DomDocument with RawData,
     * its supposed to replace Step1 results, if present, Step1 is bypassed.
     * 
     * @return mixed The report in any format, as described in current configuration.
     * @see    %sf_plugins_dir%/reportPlugin/config/sfExportConfig.yml
     */
    public function render(
        array $config, sfWebResponse $response, DomDocument $logicalScreen = null
    ) {
        
        /**
         * Step 1
         * Generates the XML input data.
         */
        if (null === $logicalScreen) {
            $logicalScreen = $this->createLogicalScreen($config);
        }
        
        /** 
         * Step 2
         * Merges the XSL-FO template with the input data by processing the XSLT
         * Actually the XSLT should containf the FO tags and <xls:> tags that 
         * handles the step1 generated xml.
         */
        $composite = CompositeFactory::getComposite($config, $logicalScreen);
        $xslFo = $composite->render();
        
        /** 
         * Step 3
         * $xslFo should contain de FO representation of the finished report.
         * Step 3 consists in generating the phisical representation, either FO
         * HTML, PDF, xls, or anything else...
         */
        return Renderer::getInstance($config)->renderReport($xslFo, $response);
    }

    /**
     * Calls user defined methos to generate input data. We call it with two 
     * params:
     * <ul>
     *   <li>Hardcoded config param, or null</li>
     *   <li>Custom Options Array, should be present in the 'options' request
     *  parameter, or an empty array()</li>
     * </ul>
     * 
     * @param array $config The configuration Array from sfExportConfig.yml
     * T
     * 
     * @return type 
     * @see    %sf_plugins_dir%/reportPlugin/config/sfExportConfig.yml
     * @see    LayoutManager::render()
     */
    public function createLogicalScreen(array $config)
    {
        PathsUtils::setPaths();
        $logicalScreen = call_user_func(
            $config['step1']['logical_screen_callback'],
            (isset($config['step1']['callback_params'])
                ? $config['step1']['callback_params']
                : null
            ),
            $config['options']
        );
        PathsUtils::deleteTmpChartFiles();
        return $logicalScreen;
    }
}
