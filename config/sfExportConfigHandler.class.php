<?php

/*
 * This file is part of the NeatReports package.
 * (c) 2011-2012 Juan Manuel Fernandez <juanmf@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/**
 * This class puts the contents of imortSchema.yml in sfConfig by making a cached
 * php version of it.
 *
 * @author Juan Manuel Fernandez <juanmf@gmail.com>
 * @see    sfYamlConfigHandler
 */
class sfExportConfigHandler extends sfYamlConfigHandler
{
    /**
     * execute this handler.
     * 
     * @param type $configFiles the Config files.
     * 
     * @return type 
     * @see %sf_plugins_dir%/NeatReports/config/sfExportGlobals.yml
     * @see %sf_plugins_dir%/NeatReports/config/sfExportConfig.yml
     */
    public function execute($configFiles) 
    {
        $config = self::getConfiguration($configFiles);
        $prefix = $this->getParameterHolder()->get('prefix', '');
        $data = '';
        foreach ($config as $key => $value) {
            $data .= sprintf(
                "'{$prefix}%s' => %s,\n",
                $key,
                var_export($value, true)
            );
        }
        $retval = "<?php\n"
                . "// date: %s\nsfConfig::add(array(\n%s));\n";
        $retval = sprintf($retval, date('Y/m/d H:i:s'), $data);
        return $retval;
    }

    /**
     * Gets config
     * 
     * @param array $configFiles Config files array
     * 
     * @return array 
     */
    static public function getConfiguration(array $configFiles)
    {
        $config = self::flattenConfiguration(self::parseYamls($configFiles));
        return $config;
    }
}
