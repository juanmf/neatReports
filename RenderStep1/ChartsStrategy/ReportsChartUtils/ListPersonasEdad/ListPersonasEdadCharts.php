<?php

/*
 * This file is part of the NeatReports package.
 * (c) 2011-2012 Juan Manuel Fernandez <juanmf@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/**
 * All Chart related stuff from ListPersonasEdad Report should be here
 * So PathsUtils contains less anoying code.
 *
 * @author Juan Manuel Fernandez <juanmf@gmail.com>
 */
class ListPersonasEdadCharts
{
    /**
     * Creates a Chart Image with the count(Year(fecha_nacimiento))
     * 
     * @param DomDocument $qResult The query result
     * 
     * @return string with the binary stream of a png picture.
     * @see listadoPersonasXedad() 
     */
    public static function listadoPersonasXedadCreateChart(DomDocument $qResult)
    {
        // Todo: add chart to /result/chart
        $xPath = new DOMXPath($qResult);
        $countedNodes = $xPath->query('/result/Persona_Collection/Persona/counted/text()');
        $count = array();
        foreach ($countedNodes as $node) {
            $count[] = $node->nodeValue;
        }
        $fechaNodes = $xPath->query('/result/Persona_Collection/Persona/years/text()');
        $years = array();
        foreach ($fechaNodes as $node) {
            $years[] = $node->nodeValue;
        }
        /* Create and populate the pData object */
        $myData = new pData();   
        $myData->addPoints($count, "Years");  
        $myData->setSerieDescription("Years", "Año de Nacimiento de las personas");

        /* Define the absissa serie */
        $myData->addPoints($years, "Labels");
        $myData->setAbscissa("Labels");

        $myPicture = self::listadoPersonasXedadConfigChart($myData);
        
        /* Create the pPie object */ 
        $pieChart = new pPie($myPicture, $myData);
        
        /* Draw AA pie chart */ 
        $pieChart->draw2DPie(200, 100, array("Border" => TRUE));

        /* Write a legend box under the 1st chart */ 
        $pieChart->drawPieLegend(90, 176, array("Style" => LEGEND_BOX, "Mode" => LEGEND_HORIZONTAL));

        /* Render the picture (choose the best way) */
        $fname = PathsUtils::createChartFileName();
        $myPicture->render($fname);
        
        $picFile = file_get_contents($fname);
        
        return $picFile;
    }
    
    /**
     * Sets fonts and sizes
     * 
     * @param pData $myData People's Years data
     * 
     * @return pImage the Chart Image Box
     */
    protected static function listadoPersonasXedadConfigChart($myData)
    {
        /* Create the pChart object */
        $myPicture = new pImage(300, 230, $myData);
        
        /* Write the picture title */ 
        $myPicture->setFontProperties(
            array("FontName" => PathsUtils::$chartFontsDir . "/Silkscreen.ttf", "FontSize" => 6)
        );
        $myPicture->drawText(
            10, 13, "Recuento de Años de nacimiento", 
            array("R" => 255, "G" => 255, "B" => 255)
        );
        
        /* Set the default font properties */ 
        $myPicture->setFontProperties(
            array(
                "FontName" => PathsUtils::$chartFontsDir . "/Forgotte.ttf", 
                "FontSize" => 10, 
                "R"        => 80, 
                "G"        => 80, 
                "B"        => 80,
            )
        );
        return $myPicture;
    }
}
