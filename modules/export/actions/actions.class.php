<?php

/*
 * This file is part of the reportPlugin package.
 * (c) 2011-2012 Juan Manuel Fernandez <juanmf@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/**
 * export actions.
 *
 * @package    Aurora
 * @subpackage ExportInformación
 * @author     Carolina <carolina@siup.gov.ar>
 * @version    Release: 1.0
 */
class exportActions extends sfActions
{
    private $_confSrc = array();

    /**
    * Executes index action
    *
    * @param sfRequest $request A request object
    * 
    * @return void
    */
    public function executeIndex(sfWebRequest $request)
    {
        $this->_confSrc = ConfigManager::includeConfig();
        $this->exportForm = new SelectReportForm(array(), $this->_confSrc);
    }

    /**
     * Render the requested Report
     * 
     * @param sfWebRequest $request The request. It's expected to have the following
     * parameters:
     * <ul>
     * <li>array<b> export</b> With the report selection and desired output rendering 
     * format.
     * <li>array<b> options</b> With custom options that wlil be pased to the callback
     * function provided by the report designer for generating the LogicalScreen.
     * <li>string<b> logicalScreen</b> With a string representation of a XML DOM. 
     * if provided, step1 gets bypassed, thus <b>options</b> param is ignored.
     * </li>
     * </ul>
     * 
     * @return sfView::NONE renderText() with the report contents.
     */
    public function executeRender(sfWebRequest $request)
    {
        $this->_confSrc = ConfigManager::includeConfig();
        $exportForm = new SelectReportForm(array(), $this->_confSrc);
        $exportForm->bind($request->getParameter('export'));
        $this->redirectUnless($exportForm->isValid(), 'export/index');
        
        $config = ConfigManager::configureExport(
            $exportForm->getValues(), 
            (array) $request->getParameter('options', array())
        );
        $dom = new DOMDocument();
        $dom = $dom->loadXML($request->getParameter('logicalScreen', null))
             ? $dom
             : null;
        
        $report = LayoutManager::getInstance()
            ->render(
                $config, 
                $this->getResponse(), 
                $dom
            );
        $this->getResponse()->setContent('');
        return $this->renderText($report);
    }
    
    /**
    * gerena parte diario
    * 
    * @param sfWebRequest $request datos recibidos
    * 
    * @return void
    *  
    * @throws Exception 
    */
    public function executeParteDiarioFo(sfWebRequest $request)
    {
        try {
            $establecimiento = $this->getUser()->getAttribute('estabPredeterm');
            $anioPlanDivision = $request->getParameter('anio_plan_division_id');
            $anioPlanDivision = Doctrine::getTable('AnioPlanDivision')
                ->find($anioPlanDivision, 'xml');
            $division = $anioPlanDivision->getDivision()->getNombre();
            $fecha = $request->getParameter('fecha');
            $fechaEsp = date('d-m-Y', strtotime($fecha));
            $titulo = 'PARTE DIARIO';
            $objPHPExcel = Informe::generarPHPExcel($titulo, 'vertical', 11.9);
            $objPHPExcel = Informe::generCabeceraParteDiario(
                $objPHPExcel, $establecimiento, $division, $fechaEsp, $titulo, $this->getUser()
            );
            $listAnioDivMateria = Doctrine::getTable('AnioDivMateria')
                ->getByAnioPlanDivisionIdAndFecha($anioPlanDivision->getId(), $fecha);

            $objPHPExcel = Informe::generarCuerpoParteDiario($objPHPExcel, $listAnioDivMateria, $fecha);
            // Rename sheet
            $objPHPExcel->getActiveSheet()->setTitle('Parte Diario Alumnos' . $fechaEsp);

            // Set active sheet index to the first sheet, so Excel opens this as the first sheet
            $objPHPExcel->setActiveSheetIndex(0);

            // Redirect output to a client’s web browser (Excel5)
            header('Content-Type: application/vnd.ms-excel');
            header('Content-Disposition: attachment;filename="PARTEDIARIO' + $fechaEsp + '.xls"');
            header('Cache-Control: max-age=0');

            $objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');
            $objWriter->save('php://output');
            //return sfView::NONE;
            die();
        } catch (Exception $exc) {
            throw $exc;
        }
    }

}
