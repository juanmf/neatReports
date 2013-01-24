<?php

/*
 * This file is part of the NeatReports package.
 * (c) 2011-2012 Juan Manuel Fernandez <juanmf@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */
namespace Juanmf\NeatReports\RenderStep2;

/**
 * This is an implementation of the Composite pattern that handles Step 2 of a 
 * three Steps Process for report Generation.
 *
 * This class' objects can not have a collection of BasicView Objects.
 * 
 * @author Juan Manuel Fernandez <juanmf@gmail.com>
 * @see    BasicView
 */
class View extends BasicView
{
    /**
     * Abstract method must be implemented, leave empty for non CompositeView
     * objects
     * 
     * @param string    $name The name of the Child BasicView
     * @param BasicView $view The Child BasicView
     * 
     * @see BasicView::addView()
     * @return void
     */
    public function addView($name, BasicView $view)
    {
    }

    /**
     * Abstract method must be implemented, leave empty for non CompositeView
     * objects
     * 
     * @param string $name The name of the Child BasicView
     * 
     * @see BasicView::getChildView()
     * @return void
     */
    public function getChildView($name)
    {
    }

    /**
     * Abstract method must be implemented, leave empty for non CompositeView
     * objects
     * 
     * @param string $name The name of the Child BasicView
     * 
     * @see BasicView::removeView()
     * @return void
     */
    public function removeView($name)
    {   
    }
}
