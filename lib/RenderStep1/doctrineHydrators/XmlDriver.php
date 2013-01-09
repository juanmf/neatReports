<?php

/**
 * This class implements an XML Hydrator for Doctrine
 * 
 * @author Juan Manuel Fernandez <juanmf@gmail.com>
 */
class Doctrine_Hydrator_XmlDriver extends Doctrine_Hydrator_ArrayDriver
{
    /**
     * Hydrates resultSet
     * 
     * @param type $stmt Statement
     * 
     * @return DomDocument the query results.
     */
    public function hydrateResultSet($stmt)
    {
        $array = parent::hydrateResultSet($stmt);
        return $this->arrayToXml($array);
    }

    /**
     * <pre>Converts a Doctrine array graph of the form:
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
     * .   &lt;rootTable_Collection&gt;
     * .     &lt;rootTable&gt;
     * .       &lt;id&gt;&lt;/id&gt;
     * .       &lt;field1&gt;&lt;/field1&gt;
     * .       &lt;relatedTable_Collection&gt;
     * .         &lt;relatedTable&gt;
     * .         &lt;/relatedTable&gt;
     * .         &lt;relatedTable&gt;
     * .        &lt;/relatedTable&gt;
     * .         ::
     * .       &lt;/relatedTable_Collection&gt;
     * .     &lt;/rootTable&gt;
     * .     &lt;rootTable&gt;
     * .       ::
     * .     &lt;/rootTable&gt;
     * .     ::
     * .   &lt;/rootTable_Collection&gt;
     * . &lt;result&gt;
     * </pre>
     */
    public function arrayToXml(array $array) 
    {
        $result = new DOMDocument();
        $rootNode = $result->createElement('result');
        $result->appendChild($rootNode);
        $iterator = new RecursiveIteratorIterator(
            new RecursiveArrayIterator($array),
            RecursiveIteratorIterator::SELF_FIRST
        );
        $prevLvl = 0;
        $component[$prevLvl] = $this->_queryComponents[$this->_rootAlias]['table']
            ->getComponentName();
        $obj = $result->createElement($component[$prevLvl] . '_Collection');
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
