<?php

/*
 * This file is part of the reportPlugin package.
 * (c) 2011-2012 Juan Manuel Fernandez <juanmf@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/**
 * This class loads reports config values.
 * 
 * @author Juan Manuel Fernandez <juanmf@gmail.com>
 * @see    %sf_plugins_dir%/reportPlugin/config/sfExportConfig.yml
 * @see    %sf_plugins_dir%/reportPlugin/config/sfExportGlobals.yml
 */
class ConfigManager
{
    /**
     * Holds the export config values from config YMLs
     * @see %sf_plugins_dir%/reportPlugin/config/sfExportConfig.yml
     * @see %sf_plugins_dir%/reportPlugin/config/sfExportGlobals.yml
     * @var array
     */
    public static $confSrc;
    
    /**
     * loads the importSchema configs into sfConfig
     * 
     * @see sfImportSchemaConfigHandler
     * @see %sf_plugins_dir%/config_handlers.yml
     * 
     * @return void
     */
    public static function includeConfig()
    {
        include_once sfContext::getInstance()->getConfigCache()
            ->checkConfig('config/sfExportGlobals.yml');
        include_once sfContext::getInstance()->getConfigCache()
            ->checkConfig('config/sfExportConfig.yml');
        ! self::$confSrc && self::$confSrc = array(
            'reports' => sfConfig::get('mod_export_reports'),
            'globals' => sfConfig::get('mod_export_globals'),
        );
        return self::$confSrc;
    }
    
    /**
     * Sets the $config parameter for rendering this report.
     * 
     * @param array $exportForm The SelectReportForm input values. Should have keys:
     * <ul>
     * <li><b>reports</b> with the name of the report to render</li>
     * <li><b>supported_output_types</b> With desired output format</li>
     * </ul>
     * @param array $options    Used for passing custom options to the Logicalscreen
     * callback.
     * 
     * @return array With the config values for step1, step2, step3. And custom 
     * options in the 'options' key of the returned Array, that will be handed to
     * the step1 callback.
     * @see LayoutManager::render()
     * @see LayoutManager::createLogicalScreen()
     */
    public static function configureExport(array $exportForm, array $options = array())
    {
        self::includeConfig();
        $config['step1'] = self::$confSrc['reports'][$exportForm['reports']]['step1'];
        $config['step2'] =
            self::$confSrc['reports'][$exportForm['reports']]['step2']['structure']['default'];
        $config['step3'] = self::$confSrc['globals']['step3'];
        $config['step3']['output_format'] = $exportForm['supported_output_types'];
        $config['options'] = $options;
        return $config;
    }
}
