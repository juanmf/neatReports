<?php

/*
 * This file is part of the reportPlugin package.
 * (c) 2011-2012 Juan Manuel Fernandez <juanmf@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/**
 * This class does nothing. It just passes throug the result from step2. Unless
 * you add a transformation stylesheet in the GlosfExportGlobalsbal config file
 * for the XSLFO output format.
 *  
 * So you can manually process it with ApacheFop or edit the XSL-FO.
 * 
 * @author Juan Manuel Fernandez <juanmf@gmail.com>
 * @see    %sf_plugins_dir%/reportPlugin/config/sfExportGlobals.yml
 * @see    Renderer
 */
class RenderFo extends Renderer
{
    /**
     * Sets the FO o FO transformation StyleSheet. In case you might want to add
     * it to the config file sfExportGlobals.yml in 
     * step3: {XSLFO: {xslt_output: sheet: ~}}.
     * 
     * @see    %sf_plugins_dir%/reportPlugin/config/sfExportGlobals.yml
     */
    public function __construct()
    {
        parent::__construct();
        $toFo = $this->_conf['step3']['XSLFO']['xslt_output']['sheet'];
        $toFo && $this->_toFo = simplexml_load_file($this->_pluginDir . $toFo);
        $this->_structure = $this->_toFo;
    }
}
