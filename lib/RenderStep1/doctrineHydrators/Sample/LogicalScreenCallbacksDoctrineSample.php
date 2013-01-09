<?php

/**
 * Sample Class copied from LogicalScreenCallbacks to show XML Hydrator.
 *
 * @author Juan Manuel Fernandez <juanmf@gmail.com>
 * @see    %sf_plugins_dir%/reportPlugin/config/sfExportConfig.yml
 */
class LogicalScreenCallbacksDoctrineSample
{
    /**
     * People listing from some Personas Table.
     * 
     * @return DomDocument With the XMLRawData that hsould be processed in Step2
     * @see LogicalScreenCallbacks::helloworld(), LayoutManager::render()
     */
    public static function listadoPersonas()
    {
        $q = Doctrine_Query::create()
            ->from('Persona p')
            ->innerJoin('p.PersonaDomicilio pd')
            ->innerJoin('pd.Domicilio d')
            ->innerJoin('d.Localidad l')
            // Here is the magic
            ->execute(array(), 'xml');  
        return $q;
        /* @var $q DomDocument */
        /*die(var_dump($q->saveXML())); // To see the XML as a String in the browser*/
        
        /** @see SampleQueryOutput.xml*/
    }
}
