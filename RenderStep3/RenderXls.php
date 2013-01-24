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
 * Unused class, we didn't finish this rendered as MS Excel opens html.
 * 
 * @todo everything on XSL
 * @author Juan Manuel Fernandez <juanmf@gmail.com> 
 */
class RenderXls extends Renderer
{
    /**
     * Document this if implementing.
     * 
     * @param DOMDocument   $xslFo    The FO
     * @param sfWebResponse $response The Response.
     * 
     * @return string The output 
     * @see Renderer::renderReport()
     */
    public function  renderReport(DOMDocument $xslFo, sfWebResponse $response = null)
    {
        $out = parent::renderReport($xslFo);
        self::$_xPath = new DOMXPath($xslFo);
        $fileName = self::$_xPath->query('//fo:title');
        $fileName = 'Report' . ((string) $fileName->item(0)) . '-' . date('Y-m-d');
        header("Content-type: application/octet-stream");
        header("Content-Disposition: attachment; filename=$fileName.xls");
        header("Pragma: no-cache");
        header("Expires: 0");
        return $out;
    }
}

