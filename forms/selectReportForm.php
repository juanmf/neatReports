<?php

/*
 * This file is part of the NeatReports package.
 * (c) 2011-2012 Juan Manuel Fernandez <juanmf@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/**
 * This form gets all suported output formats from config and all configured 
 * reports and listes them for the user to select from.
 *
 * @author Juan Manuel Fernandez <juanmf@gmail.com>
 */
class SelectReportForm extends sfForm
{
    /**
     * Configures this Form
     * 
     * @return void
     */
    public function configure()
    {
        $this->disableLocalCSRFProtection();
        $reports = $this->getReports();
        $supported = $this->getSupportedTypes();
        $reportsChoise = new sfWidgetFormChoice(
            array(
                'choices' => array($reports),
                'label'   => 'Planillas',
            )
        );
        $supportedOutputTypes = new sfWidgetFormChoice(
            array(
                'choices' => array($supported),
                'label'   => 'Formato de archivo',
            )
        );
        $this->setWidgets(
            array(
                'reports'                => $reportsChoise,
                'supported_output_types' => $supportedOutputTypes,
            )
        );
        
        $reportsVaidator = new sfValidatorChoice(
            array('choices' => array_keys($reports), 'required' => true)
        );
        $supportedOutputTypesValidator = new sfValidatorChoice(
            array('choices' => $supported, 'required' => true)
        );
        $this->setValidators(
            array(
                'reports'                => $reportsVaidator,
                'supported_output_types' => $supportedOutputTypesValidator,
            )
        );
        $this->widgetSchema->setNameFormat('export[%s]');
        $this->errorSchema = new sfValidatorErrorSchema($this->validatorSchema);
    }

    /**
     * Retrieve all reports available in configuration.
     * 
     * @return array With the reports's names.
     * @see %sf_plugins_dir%/NeatReports/config/sfExportGlobals.yml
     * @see %sf_plugins_dir%/NeatReports/config/sfExportConfig.yml
     */
    public function getReports()
    {
        $reports = array();
        foreach ($this->options['reports'] as $key => $reportDef) {
            $reports[$key] = $reportDef['name'];
        }
        return $reports;
    }

    /**
     * Retrieve all supported report types i.e. [HTML, XSLFO]
     * 
     * @return array With the supported sheet types.
     * @see %sf_plugins_dir%/NeatReports/config/sfExportGlobals.yml
     */
    public function getSupportedTypes()
    {
        return array_combine(
            $this->options['globals']['step3']['available_output'],
            $this->options['globals']['step3']['available_output']
        );
    }
}
