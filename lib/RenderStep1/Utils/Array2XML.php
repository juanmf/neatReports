<?php

/*
 * This file is part of the reportPlugin package.
 * (c) 2011-2012 Juan Manuel Fernandez <juanmf@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/**
 * Utility class to turn Arrays into XML, code is almost identical to Doctrine
 * Hidrator Doctrine_Hydrator_XmlDriver, just that it doesn't need to be a 
 * Doctrine query result
 * 
 * @author Juan Manuel Fernandez <juanmf@gmail.com>
 * @see    Doctrine_Hydrator_XmlDriver::arrayToXml()
 */
class Array2XML
{
    /**
     * <pre>Converts an array graph of the form:
     * .array
     * .  0 =>
     * .    array
     * .      'id' => '1'
     * .      'PersonaDomicilio' =>
     * .        array
     * .          0 =>
     * .            array
     * .              'id' => '1'
     * To a XML representation.
     * 
     * @param array $array The array to convert to XML
     * 
     * @return DOMDocument <pre> The XML with following structure:
     * . &lt;result&gt;
     * .   &lt;Collection&gt;
     * .     &lt;rootArray&gt;
     * .       &lt;id&gt;&lt;/id&gt;
     * .       &lt;field1&gt;&lt;/field1&gt;
     * .       &lt;relatedArray_Collection&gt;
     * .         &lt;relatedArray&gt;
     * .         &lt;/relatedArray&gt;
     * .         &lt;relatedArray&gt;
     * .        &lt;/relatedArray&gt;
     * .         ::
     * .       &lt;/relatedArray_Collection&gt;
     * .     &lt;/rootArray&gt;
     * .     &lt;rootArray&gt;
     * .       ::
     * .     &lt;/rootArray&gt;
     * .     ::
     * .   &lt;/rootArray_Collection&gt;
     * . &lt;result&gt;
     * </pre>
     */
    public static function arrayToXml(array $array) 
    {
        $result = new DOMDocument();
        $rootNode = $result->createElement('result');
        $result->appendChild($rootNode);
        $iterator = new RecursiveIteratorIterator(
            new RecursiveArrayIterator($array),
            RecursiveIteratorIterator::SELF_FIRST
        );
        $prevLvl = 0;
        $obj = $result->createElement('Collection');
        $rootNode->appendChild($obj);
        foreach ($iterator as $k => $val) {
            $depth = $iterator->getDepth();
            if ($depth < $prevLvl) {
                for ($i = 0; $i < ($prevLvl - $depth); $i++) {
                    $obj = $obj->parentNode;
                }
            }
            if (! is_array($val)) {
                $son = $result->createElement($k, $val);
                $obj->appendChild($son);
            } else {
                if (is_numeric($k)) {
                    $son = $result->createElement($component[$depth]);
                } else {
                    $component[$depth + 1] = $k;
                    $son = $result->createElement($k . '_Collection');
                }
                $obj->appendChild($son);
                !empty($val) && $obj = $son;
            }
            $prevLvl = $depth;
        }
        return $result;
    }
}