<?php

/*
 * This file is part of the NeatReports package.
 * (c) 2011-2012 Juan Manuel Fernandez <juanmf@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */
namespace Juanmf\NeatReports\RenderStep1\Utils;

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
     * .[0 => {
     * .      'id' => '1',
     * .      'PersonAddress' => [
     * .          0 => {
     * .               'id' => '1'
     * .               'st' => 'someStreet'
     * .               }
     * .      },
     * . 1 => {
     * .      'id' => '2',
     * .      'PersonAddress' => [
     * .          0 => {
     * .               'id' => '12'
     * .               'st' => 'someOtherStreet'
     * .               }
     * .      }
     * .]
     * 
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
        $prevLvl = 0;
        $entityCollectionStack[$prevLvl] = 'Collection';
        $result = new DOMDocument();
        $rootNode = $result->createElement('result');
        $result->appendChild($rootNode);
        $obj = $result->createElement($entityCollectionStack[$prevLvl]);
        $rootNode->appendChild($obj);
        
        $iterator = new RecursiveIteratorIterator(
            new RecursiveArrayIterator($array),
            RecursiveIteratorIterator::SELF_FIRST
        );
        foreach ($iterator as $k => $val) {
            $depth = $iterator->getDepth();
            // Move up in hierarchy, if descendents parsing finished.
            if ($depth < $prevLvl) {
                // TODO: this can be faster with a stack of nodes, that'd replace 
                // the for loop with a $obj = $objStack[$depth];
                // by caching the $obj in line(~114): !empty($val) && $obj = $son;
                for ($i = 0; $i < ($prevLvl - $depth); $i++) {
                    $obj = $obj->parentNode;
                }
            }
            // Add entity properties or repations (subArrays)
            if (! is_array($val)) {
                // Add scalar value, i.e. (id = 2) and continue.
                $son = $result->createElement($k, $val);
                $obj->appendChild($son);
            } else {
                /* Either the next instance of the current enumerative array 
                 * (with numeric key). Or a new Collection of related entities
                 * (with the related entity name as key ($k))
                 */
                if (is_numeric($k)) {
                    $son = $result->createElement($entityCollectionStack[$depth]);
                } else {
                    /* Collection of entities is a named key which value is an 
                     * enumerative array or entity attribs: 
                     * 'PersonAddress' => [0 => {id => 1,..}, 1 => {id => 2,..}]
                     */
                    $entityCollectionStack[$depth + 1] = $k;
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
