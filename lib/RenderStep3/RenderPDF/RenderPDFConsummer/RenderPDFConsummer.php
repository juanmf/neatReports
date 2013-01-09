<?php

/*
 * This file is part of the reportPlugin package.
 * (c) 2011-2012 Juan Manuel Fernandez <juanmf@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/**
 * Description of renderPDFConsummer
 * 
 * @author Juan Manuel Fernandez <juanmf@gmail.com>
 */
class RenderPDFConsummer
{
    public $pdf = null;
    public $xsl = null;
    public $xml = null;
    public $xslFo = null;
    
    //Configuración del servicio:
    private $_wsUri = 'http://web.fopwrapper.apps.siup.gov/';
    // private $_wsLocation = 'http://172.17.0.3:8080/WebFOPWrapper2-war/DecretoRenderService';
     private $_wsLocation = 'http://juanmf-PC:8080/DecretoRenderService/DecretoRender';
    private $_wsTrace = 0;
    
    /**
     * Constructor con Sobrecarga simulada, (PHP no soporta sobrecarga :( )
     * si dispones del XSLFO manda solo eso como parametro. Si dispones del
     * XSL y el XML manda los dos. Pero nunca un XSLFO y un XML.
     * 
     * @param string $xslFo The XSL-FO
     * @param string $xml   The Data
     */
    public function __construct($xslFo, $xml= null) 
    {
        //Si vienen dos parametros en realidad xslFo esun XSLT de transformacion.
        if (!is_null($xslFo) && is_null($xml)) {
            $this->xslFo = $xslFo;
            $this->_loockUpPDFXslFo();
        } else if (!is_null($xslFo) && !is_null($xml)) {
            $this->xsl = $xslFo;
            $this->xml = $xml;
            $this->_loockUpPDFXslXml();
        }        
    }

    /**
     * Realiza la llamada SOAP al webservice que implementa la interfaz con el
     * Wrapper de Apache FOP (gov.siup.apps.fopwrapper.decretos.DecretoRenderer).
     *
     * Espera obtener elcontenido del PDF que resulta de procesar el XSLFO que
     * se envía como parametro ($this->xslFo).
     * 
     * @return void
     */
    private function _loockUpPDFXslFo() 
    {
        if ($this->xslFo) {
            $options = array(
                'uri'      => $this->_wsUri,
                'location' => $this->_wsLocation,
                'trace'    => $this->_wsTrace,
            );
            $soapClient = new SoapClient(null, $options);
            try {
                $retBase64 = $soapClient->renderPDF_1(new SoapParam($this->xslFo, 'xslFo'));
                $this->pdf = base64_decode($retBase64);
            } catch (SoapFault $soapFault) {
                if ($this->_wsTrace == 1 ) {
                    error_log($soapFault->getMessage());
                    die(var_dump($soapFault));
                }
                throw $soapFault;
            }
        } else {
            throw new Exception("XSLFO vacío.");
        }
    }
    
    /**
     * Realiza la llamada SOAP al webservice que implementa la interfaz con el
     * Wrapper de Apache FOP (gov.siup.apps.fopwrapper.decretos.DecretoRenderer).
     *
     * Espera obtener elcontenido del PDF que resulta de procesar el XSL y el XML que
     * se envían como parametro ($this->xsl, $this->xml).
     * 
     * @return void
     */
    private function _loockUpPDFXslXml() 
    {
        if (!is_null($this->xsl) && !is_null($this->xml)) {
            $options = array(
                'uri'      => $this->_wsUri,
                'location' => $this->_wsLocation,
                'trace'    => $this->_wsTrace,
            );
            $soapClient = new SoapClient(null, $options);
            try {
                $retBase64 = $soapClient->renderPDF_2(
                    new SoapParam($this->xsl, 'xslT'),
                    new SoapParam($this->xml, 'xml')
                );
                $this->pdf = base64_decode($retBase64);
            } catch (SoapFault $soapFault) {
                if ($this->_wsTrace == 1 ) {
                    error_log($soapFault->getMessage());
                    die(var_dump($soapFault));
                }
                throw $soapFault;
            }
        } else {
            throw new Exception("XSLFO vacío.");
        }
    }
    
    /**
     * Devuelve un String con el contenido del PDF.
     *
     * @return String Con el contenido del PDF.
     */
    public function getPdfStream() 
    {
        return $this->pdf;
    }
    
    /**
     * Genera un archivo con el contenido del PDF devuelve un Handler de dicho
     * archivo.
     * Es responsabilidad del codigo usuario cerrar el archivo. fclose($filename)
     *
     * @param String $filename The filename
     * 
     * @return resource FileHandler resultado de fopen($filename)
     */
    public function getPdfFile($filename) 
    {
        try {
            $filePointer = fopen($filename, "w+b");
            fputs($filePointer, $this->pdf, strlen($this->pdf));
            fclose($filename);
            $filePointer = fopen($filename, "r");
        } catch (Exception $exc) {
            throw $exc;
        }
        return $filePointer;
    }
    
    /**
     * Arma los Headers y anexa el contenido del pdf para que el browser
     * inicie la descarga.
     * Importante, al llamar a esta funcion no se debe imprimir nada en la salida
     * NO echo!
     * 
     * @param String $filename Nombre que se asigna en el cliente al archivo.
     * 
     * @return void
     */
    public function sendFile($filename = '') 
    {
        if (!$filename) {
            //año-mes-dia-hora-minuto-segundo
            $filename = date('o-m-d-G-i-s') . ".pdf";
        }
        header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
        header("Last-Modified: " . gmdate("D,d M YH:i:s") . " GMT");
        header("Cache-Control: no-cache, must-revalidate");
        header("Pragma: no-cache");
        header("Content-Type: application/pdf");
        header("Content-Disposition: attachment; filename=" . $filename);
        echo $this->getPdfStream();
    }
}
