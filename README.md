reportPlugin
============

Report Plugin is a tool for generating reports with PHP, even though it provides 
a PHP API it integrates several technologies to achieve it.
The reports are generated in three phases:
   * Data Generation 
   * Data and template Merging.
   * Rendering

The Data generation consists of anything that produces a RAW XML with the report 
data. Of course, this XML structure must be consistent among several rendering of 
the same report. Since you will consider this structure when creating the 
template, as the template must consume this data XML. The reportEngine provides
a placeholder class for putting this kind of logic, but you can generate it in
methods elsewhere, so you either provide the callback to generate it or the XML
itself. To make things easier, a Doctrine XML Hydrator is bundled so you can get 
XML out of your Doctrine Queries, this is really handy if you use Doctrine, if not
you have an arrayToXML method in utils, that will also help.. 

The template must be an XSLT transformation stylesheet, that will be processed by
PHP XSLT Processor, don't get scared yet, I provide an automatic way of generating 
it from a MS WordML 2003 document. This stylesheet consumes your data XML and 
Renders a XSL-FO document, that represents the rendered report, but in FO. 
The report must still go through the Rendering phase, if you want something different 
from XSL-FO.

In the Rendering phase transforms the XSL-FO representation into PDF, HTML, or simply 
the same FO. more transformations can be easily added.

The look and feel of the generated PDFs are great, thanks to XSL-FO and ApacheFOP. 
They look almost identical to the Word template you make (Thanks to Word2FO).
By the time you feel the need to tweak the automatically generated template, if it 
ever happens, you'll have already made some nice reports and feel more at home 
with XSLT and XSL-FO. which by the way is infinitely easier to tweak than to 
write from scratch.

Take a look at the HowToReport to see what can be done: 
https://github.com/juanmf/sfPlugins/blob/master/reportPlugin/doc/HowToReport.pdf?raw=true

Dependencies
============

ReportPugin has the following dependencies, some of which (Word2FO and fo2html) I can't package all together:

* Word2FO a great tool from RenderX http://www.renderx.com/tools/word2fo.html . I made a Stylesheet (*Word2XSLTRenderingFO.xsl*) that depends on this one, so that you can create XSLT stylesheets that consume XML data instead of a final XSLFO document. Even though I didn't package Word2FO, all you need to do is download it and decompress it in *reportPlugin/doc* directory. RenderX.com will ask for your mail to let you download the stylesheet, which comes with full license (text from RenderX's page ..."These stylesheets were prepared by RenderX's development team and Microsoft for general use."...). This is used for templating, not in the rendering process, but it makes life easier. How to edit Word Documents to take advantage of my changes is detailed in reportPlugin\doc\HowToReport.docx
* ApacheFOP an open source FO Processor, made in java, for which I made a wrapper and some classes to consume it as a web service (you must deploy it on an application server for that, i.e. Glassfish) or from Command line. This one comes bundled.
* fo2html.xsl Also from RendeX (http://services.renderx.com/Content/tools/fo2html.html), which I modified a bit, not finished nor tested yet, to generate HTML that Excel understands, and alter default table width. This is used for rendering the report in HTML. You should put this stylesheet in reportPlugin\lib\RenderStep3\xsl\fo2html.xsl to match sfExportGlobals.yml configuration
Note: you can find both stylesheets in the Free tools Section at http://www.renderx.com/download/shop.html

The user manual is located at reportPlugin/doc/HowToReport.docx
You will need to apply the patch to Word2FO stylesheets before it 
works as described. If you don't apply it, then you get a XSLFO that 
mimics the WordML instead of a stylesheet you can use to transform your raw XML data.

1) You need to enable php_soap.dll & php_xsl.dll extensions 

2) Register Plugin in ProjectConfiguration.php

3) Enable_module "export" in setting.yml

4) Copy reportPlugin/config/sfExportConfig.yml to app/config

5) In sfExportConfig.yml you define the location of you reports XSLT stylesheets

6) To see some example reports copy reportPlugin/modules/export/templates/reports
directory to app/templates
7) You can open <domain>/export to see what reports you have defined, and test them.

8) @see reportPlugin/modules/export/actions/actions.class.php (render action) for
an example of how to use LayoutManager::render()

9) install Glassfish, from Netbeans, (Optional as you also have a Renderer for FOP from the CLI):

  9.1) open the project WebFopWrapper2
  
  9.2) right click => clean and build
  
  9.3) right click => deploy
  
  9.3.1) fin in the output the following URL:
  
    |  INFO: WS00019: EJB Endpoint deployed
    
    |   WebFOPWrapper2  listening at address at http://juanmf-PC:8080/DecretoRenderService/DecretoRender
    
  this should match the value of RenderPDFConsummer::$_wsLocation (I'll put this 
value in config yml soon)


 