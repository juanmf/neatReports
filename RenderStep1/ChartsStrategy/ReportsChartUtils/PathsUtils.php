<?php

/*
 * This file is part of the NeatReports package.
 * (c) 2011-2012 Juan Manuel Fernandez <juanmf@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */
namespace Juanmf\NeatReports\RenderStep1\ChartsStrategy\ReportsChartUtils;

/**
 * Contains temporary paths generation and deletion logic
 *
 * @author Juan Manuel Fernandez <juanmf@gmail.com>
 */
class PathsUtils
{
    public static $chartFontsDir = '/../vendor/pChart2.1.3/fonts';
    public static $chartPicsDir = '/../ChartPictures';
    public static $tmpFilesToDelete = array();

    /**
     * Convenience method to track temp filenames and delete them after used. 
     * I.e. just before starting Step2
     * 
     * @return string the file name to use.
     * @see LayoutManager::render()
     */
    public static function createChartFileName()
    {
        $tstmp = microtime(true);
        $fName = self::$chartPicsDir . "/chart-$tstmp.png";
        self::$tmpFilesToDelete[] = $fName;
        return $fName;
    }
    
    /**
     * Convenience method to delete generated files after being used.
     * I.e. just before starting Step2
     * 
     * @return void
     * @see LayoutManager::render()
     */
    public static function deleteTmpChartFiles()
    {
        foreach (self::$tmpFilesToDelete as $fileName) {
            unlink($fileName);
        }
        self::$tmpFilesToDelete = array();
    }
    
    /**
     * Sets paths that comes handy with charts.
     * 
     * @return void
     */
    public static function setPaths()
    {
        self::$chartFontsDir = __DIR__ . self::$chartFontsDir;
        self::$chartPicsDir = __DIR__ . self::$chartPicsDir;
    }    
}
