
function file_to_md (filename)
  qid=nil
  for line in io.lines(filename) do

    if (not(quoteverbatim) and not(skipline) and string.match(line,"\\begin{verbatim}")) then
      line=string.gsub(line,"\\begin{verbatim}","```latex")
      verbatim=true
    end
    if (not(skipline) and string.match(line,"\\begin{quoteverbatim}")) then
      line=string.gsub(line,"\\begin{quoteverbatim}","```latex")
      quoteverbatim=true
    end

    if (verbatim or quoteverbatim) then
    
      if (verbatim and string.match(line,"\\end{verbatim}")) then
        line=string.gsub(line,"\\end{verbatim}","```")
        verbatim=false
      end
      if (quoteverbatim and string.match(line,"\\end{quoteverbatim}")) then
        line=string.gsub(line,"\\end{quoteverbatim}","```")
        quoteverbatim=false
      end
      
      -- Indent in lists
      if itemize or enumerate then
        line = "    " .. line
      end

    else -- not verbatim

      if(string.match(line,"\\section{")) then
        section=faq_convert_line((string.gsub(line,".*\\section{(.*)} *$","%1")))
	secid=string.gsub(section,"[^%a]","")
	subsecid=nil
        line=(introduction and "<h2>" .. section .. "</h2>") or ""
      end

      if(string.match(line,"\\subsection{")) then
        subsection=faq_convert_line((string.gsub(line,".*\\subsection{(.*)} *$","%1")))
	subsecid=string.gsub(subsection,"[^%a]","")
        line=(introduction and "<h3>" .. subsection .. "</h3>") or ""
      end

      if(string.match(line,"\\begin{introduction}")) then
        line=""
	qid=nil
        introduction=true
  
        io.output("index.md")
        io.write("<!DOCTYPE html>\n<html>\n<head>\n")
        io.write("<meta charset=\"UTF-8\">\n")
        io.write("<title>UKTUG FAQ</title>\n")
        io.write("<link rel=\"stylesheet\" href=\"faq.css\">\n")
        io.write("</head>\n<body>\n")
	io.write("<h1>Welcome to the UK List of<br>\n")
  	io.write("TeX Frequently Asked Questions</h1>\n")
	io.write("<script>  (function() {")
	io.write("var cx = '012439869432470945129:rdb1e0hqrou';")
	io.write("var gcse = document.createElement('script');")
	io.write("gcse.type = 'text/javascript';")
	io.write("gcse.async = true;")
	io.write("gcse.src = (document.location.protocol == 'https:' ? 'https:' : 'http:') +")
	io.write("'//cse.google.com/cse.js?cx=' + cx;")
	io.write("var s = document.getElementsByTagName('script')[0];")
	io.write("s.parentNode.insertBefore(gcse, s);")
	io.write("})();\n")
	io.write("</script>\n")
	io.write("<div class=\"gcse-search\"></div>")

      end


      if(string.match(line,"\\end{introduction}")) then
        line=""
        introduction=false
	faq_make_toc()
	qid=nil
      end


      if(string.match(line,"^[ ]*\\Question%[")) then
        qid=string.gsub(line,".*\\Question%[([^%]]*)]{(.*)} *$","%1")
        qid=string.gsub(qid,"%*","star")
        qtitle=faq_convert_line((string.gsub(line,".*\\Question%[([^%]]*)]{(.*)} *$","%2")))
	qtitletext=string.gsub(qtitle,"<[^<>]*>","")
        line=""

--        print("XXX: " .. qid)
  
        io.output("FA" .. qid .. ".md")
        
        io.write("---\n")
        io.write("layout: page\n")
        io.write("title: " .. qtitle .. "\n")
        io.write("permalink: /FA" .. qid .. ".html\n")
        io.write("---\n")

    end

      line=faq_convert_line(line)
    end
    if (verbatim or not string.match(line,"^ *$")) then
      io.write(line .. "\n")
    end
  end
  qid=nil
end

function faq_convert_line (line)
    line=string.gsub(line,"^[ ]*$","\n")
    line=string.gsub(line,"\\par{}","\n") --why?

    line=string.gsub(line,"%-%-%-","&mdash;")
    line=string.gsub(line,"%-%-","&ndash;")
    line=string.gsub(line,"~","&nbsp;")
    line=string.gsub(line,"\\nobreakspace{}","&nbsp;")
    line=string.gsub(line,"\\nobreakspace","&nbsp;")
    line=string.gsub(line,"\\textless","<")
    line=string.gsub(line,"\\textgreater",">")
    line=string.gsub(line,"\\textsterling{}","&#xa3;")
    line=string.gsub(line,"\\pounds{}","&#xa3;")
    line=string.gsub(line,"\\%%","&#x25;;")
    line=string.gsub(line,"\\{","{")
    line=string.gsub(line,"\\obracesymbol{}","{")
    line=string.gsub(line,"\\}","}")
    line=string.gsub(line,"\\cbracesymbol{}","}")
    line=string.gsub(line,"\\%$","$")
    line=string.gsub(line,"\\ae[ ]*{}","&aelig;")
    line=string.gsub(line,"\\ss[ ]*{}","&szlig;")
    line=string.gsub(line,"\\ss ","&szlig;")
    line=string.gsub(line,"\\bsbs([^%a])","&#x5c;%1")
    line=string.gsub(line,"\\relax([^%a])","%1")
    line=string.gsub(line,"\\protect([^%a])","%1")
    line=string.gsub(line,"\\textemdash([^%a])","&mdash;%1")
    line=string.gsub(line,"\\textasciicircum([^%a])","^%1")
    line=string.gsub(line,"\\textasciitilde([^%a])","&#x7e;%1")
    line=string.gsub(line,"\\textpercent[ ]*{}","%%")
    line=string.gsub(line,"\\textcurrency[ ]*{}","&#xa4;")
    line=string.gsub(line,"\\texteuro[ ]*{}","&#x20ac;")
    line=string.gsub(line,"\\textbackslash([^%a])","&#x5c;%1")
    line=string.gsub(line,"\\textbar([^%a])","&#x7c;%1")
    line=string.gsub(line,"\\arrowhyph[ ]*{}","&rarr;")


    line=string.gsub(line,"\\`([aoe])","&%1grave;")
    line=string.gsub(line,"\\'([aoe])","&%1acute;")
    line=string.gsub(line,"\\\"([aoeu])","&%1uml;")
    line=string.gsub(line,"\\^([aoe])","&%1circ;")
    line=string.gsub(line,"\\&amp;","&")
    line=string.gsub(line,"\\pi([^%a])","&pi;%1")
    line=string.gsub(line,"\\@([^%a])","%1")

    line=string.gsub(line,"``","''")

    line=string.gsub(line,"`","'")

    line=string.gsub(line,"%%.*","")

    line=string.gsub(line,"\\keywords[ ]*{(.*)}","<!-- %1 -->")


    line=string.gsub(line,"\\ctan{}","CTAN")

    line=string.gsub(line,"\\plaintex{}","Plain TeX")
    line=string.gsub(line,"\\Eplain}","Eplain}") -- hmmm
    line=string.gsub(line,"\\Eplain{}","Eplain")
    line=string.gsub(line,"\\PS{}","PostScript")
    line=string.gsub(line,"\\YandY{}","Y&amp;Y")
    line=string.gsub(line,"\\WYSIWYG{}","WYSIWYG")
    line=string.gsub(line,"\\CDROM{}","CD-ROM")
    line=string.gsub(line,"\\eTeX{}","e-TeX") -- why both?
    line=string.gsub(line,"\\etex{}","e-TeX")
    line=string.gsub(line,"\\TeX{}","TeX")-- why both?
    line=string.gsub(line,"\\tex{}","TeX")
    line=string.gsub(line,"\\ExTeX{}","ExTeX")
    line=string.gsub(line,"\\Omega{}","&Omega;")
    line=string.gsub(line,"\\Omega([^%a])","&Omega;%1")
    line=string.gsub(line,"\\beta([^%a])","&beta;%1")
    line=string.gsub(line,"\\elatex{}","e-LaTeX")
    line=string.gsub(line,"\\latex{}","LaTeX")
    line=string.gsub(line,"\\latex([^%a])","LaTeX%1")
    line=string.gsub(line,"\\twee{}","2<sub>&epsilon;</sub>")
    line=string.gsub(line,"\\PiCTeX{}","PicTeX")
    line=string.gsub(line,"\\pictex{}","PicTeX")
    line=string.gsub(line,"\\LuaTeX{}","LuaTeX") -- why both?
    line=string.gsub(line,"\\luatex{}","LuaTeX")
    line=string.gsub(line,"\\xetex{}","XeTeX")
    line=string.gsub(line,"\\NTS{}","NTS")
    line=string.gsub(line,"\\texworks{}","TeXworks")
    line=string.gsub(line,"\\texshop{}","TeXshop")
    line=string.gsub(line,"\\miktex{}","MiKTeX")
    line=string.gsub(line,"\\texlive{}","texlive")
    line=string.gsub(line,"\\PDFTeX{}","PDFTeX")-- why both?
    line=string.gsub(line,"\\pdftex{}","PDFTeX")
    line=string.gsub(line,"\\AMSLaTeX{}","AMSLaTeX")
    line=string.gsub(line,"\\amslatex{}","AMSLaTeX")
    line=string.gsub(line,"\\AMSTeX{}","AMSTeX")
    line=string.gsub(line,"\\CONTeXT{}","CONTeXT")
    line=string.gsub(line,"\\context{}","Context")
    line=string.gsub(line,"\\PDFLaTeX{}","PDFLaTeX")-- why both?
    line=string.gsub(line,"\\pdflatex{}","PDFLaTeX")
    line=string.gsub(line,"\\BibTeX{}","BibTeX") -- why both?
    line=string.gsub(line,"\\bibtex{}","BibTeX")
    line=string.gsub(line,"\\[Mm][Pp]{}","MetaPost")
    line=string.gsub(line,"\\[Mm][Ff]{}","MetaFont")
    line=string.gsub(line,"\\ttype{}","TrueType")
    line=string.gsub(line,"\\otype{}","OpenType")
    line=string.gsub(line,"\\AllTeX{}","(La)TeX")
    line=string.gsub(line,"\\alltex{}","(La)TeX")
    line=string.gsub(line,"\\LaTeX{}","LaTeX")
    line=string.gsub(line,"\\LaTeXo{}","LaTeX 2.09")
    line=string.gsub(line,"\\latexo{}","LaTeX 2.09")
    line=string.gsub(line,"\\LaTeXe{}","LaTeX 2e") -- why both?
    line=string.gsub(line,"\\latexe{}","LaTeX 2e")

    
    line=string.gsub(line,"\\TUGboat{}","TUGboat") -- make link?
    line=string.gsub(line,"\\TUGboat([^%a])","TUGboat%1") -- hmm
    line=string.gsub(line,"\\BV{}","Baskerville") -- make link?
    line=string.gsub(line,"\\The[ ]*{}","Th&#x1ebf;")


    line=string.gsub(line,"\\dots$","&hellip;") --hmm
    line=string.gsub(line,"\\dots{}","&hellip;")
    line=string.gsub(line,"\\dots([^%a])","&hellip;%1") -- hmm

    line=string.gsub(line,"\\MSDOS{}","MSDOS")
    line=string.gsub(line,"\\macosx{}","Mac OS/X")

    line=string.gsub(line,"\\Package[ ]*{([^{}]*)}","[`%1`](http://ctan.org/pkg/%1)")
    line=string.gsub(line,"\\package[ ]*{([^{}]*)}","[`%1`](http://ctan.org/pkg/%1)")
    line=string.gsub(line,"\\Class[ ]*{([^{}]*)}","[`%1`](http://ctan.org/pkg/%1)")
    line=string.gsub(line,"\\ProgName[ ]*{([^{}]*)}","`%1`")
    line=string.gsub(line,"\\progname[ ]*{([^{}]*)}","`%1`")
    line=string.gsub(line,"\\FontName[ ]*{([^{}]*)}","`%1`")
    line=string.gsub(line,"\\File[ ]*{([^{}]*)}","`%1`")
    line=string.gsub(line,"\\Newsgroup[ ]*{([^{}]*)}","`%1`")
    line=string.gsub(line,"\\extension[ ]*{([^{}]*)}","`%1`")
    line=string.gsub(line,"\\ltxcounter[ ]*{([^{}]*)}","`%1`")
    line=string.gsub(line,"\\FontFormat[ ]*{([^{}]*)}","`%1`")
    line=string.gsub(line,"\\pkgoption[ ]*{([^{}]*)}","`%1`")
    line=string.gsub(line,"\\environment[ ]*{([^{}]*)}","`%1`")
    line=string.gsub(line,"\\meta[ ]*(%b{})","&lsaquo;_QQQ%1ZZZ_&rsaquo;")
    line=string.gsub(line,"\\acro[ ]*{([^{}]*)}","%1")
    line=string.gsub(line,"\\ensuremath[ ]*{([^{}]*)}","%1")

    line=string.gsub(line,"\\cmdinvoke([%*]*)(%b{})(%b{})(%b{})(%b{})(%b{})","`\\QQQ%2ZZZ{QQQ%3ZZZ}{QQQ%4ZZZ}{QQQ%5ZZZ}{QQQ%6ZZZ}`")
    line=string.gsub(line,"\\cmdinvoke([%*]*)(%b{})(%b{})(%b{})(%b{})","`\\QQQ%2ZZZ{QQQ%3ZZZ}{QQQ%4ZZZ}{QQQ%5ZZZ}`")
line=string.gsub(line,"\\cmdinvoke([%*]*)(%b{})(%b{})(%b{})","`\\QQQ%2ZZZ{QQQ%3ZZZ}{QQQ%4ZZZ}`")
    line=string.gsub(line,"\\cmdinvoke([%*]*)(%b{})(%b[])(%b{})(%b{})","`\\QQQ%2ZZZ%3{QQQ%4ZZZ}{QQQ%5ZZZ}`")
    line=string.gsub(line,"\\cmdinvoke([%*]*)(%b{})(%b[])(%b{})","`\\QQQ%2ZZZ%3{QQQ%4ZZZ}`")

line=string.gsub(line,"\\cmdinvoke([%*]*)(%b{})(%b{})(%b[])(%b{})","`\\QQQ%2ZZZ{QQQ%3ZZZ}%4{QQQ%5ZZZ}`")

line=string.gsub(line,"\\cmdinvoke([%*]*)(%b{})(%b{})","`\\QQQ%2ZZZ{QQQ%3ZZZ}`")
    line=string.gsub(line,"\\cmdinvoke([%*]*)(%b{})(%b[])","`\\QQQ%2ZZZ%3`")
    line=string.gsub(line,"\\csx[ ]*(%b{})","`\\QQQ%1ZZZ`")
    line=string.gsub(line,"\\marg[ ]*(%b{})","{QQQ%1ZZZ}")
    line=string.gsub(line,"|%(\\end([^|]*)<|","<code class=\"verb\">&#x5c;end%1&gt;</code>")-- short verb allowed?
    line=string.gsub(line,"|%{\\it stuff([^|]*}|","<code class=\"verb\">{&#x5c;it stuff&#x7d;</code>")-- short verb allowed?
    line=string.gsub(line,"|\\def\\x b{xxxb}|","<code class=\"verb\">&#x5c;def&#x5c;x b&#7b;xxxb&#x7d;</code>")-- short verb allowed?
    line=string.gsub(line,"|\\def\\x #1{xxx#1}|","<code class=\"verb\">&#x5c;def&#x5c;x #1{xxx#1&#x7d;</code>")-- short verb allowed?
    line=string.gsub(line,"|p{%.%.%.}|","<code class=\"verb\">p{...&#x7d;</code>")-- short verb allowed?
    line=string.gsub(line,"|([^ |]*)|", "`%1`")
    line=string.gsub(line,"\\textsf[ ]*(%b{})","QQQ%1ZZZ")
    line=string.gsub(line,"\\textup[ ]*(%b{})","QQQ%1ZZZ")
    line=string.gsub(line,"\\textsl[ ]*(%b{})","_QQQ%1ZZZ_")
    line=string.gsub(line,"{}\\texttt[ ]*(%b{})","`QQQ%1ZZZ`")-- breaking -- ligs
    line=string.gsub(line,"\\texttt[ ]*(%b{})","`QQQ%1ZZZ`")
    line=string.gsub(line,"\\path[ ]*(%b{})","`QQQ%1ZZZ`")
    line=string.gsub(line,"\\emph[ ]*(%b{})","_QQQ%1ZZZ_")
    line=string.gsub(line,"\\textbf[ ]*(%b{})","*QQQ%1ZZZ*")
    line=string.gsub(line,"\\textit[ ]*(%b{})","_QQQ%1ZZZ_")
    line=string.gsub(line,"\\paragraph[ ]*(%b{})","#### QQQ%1ZZZ")

    line=string.gsub(line,"\\ISBN%*(%b{})(%b{})","ISBN-10 QQQ%1ZZZ, ISBN-13 QQQ%1ZZZ")
    line=string.gsub(line,"\\ISBN(%b{})","ISBN-10 QQQ%1ZZZ")

    line=string.gsub(line,"\\\\%b[]","\n")
    line=string.gsub(line,"\\\\","\n")
    line=string.gsub(line,"\\,"," ")
    line=string.gsub(line,"\\quad ","\n")
    line=string.gsub(line,"\\ "," ")
    line=string.gsub(line,"\\[be]group([^%a])","%1")
    
    line=string.gsub(line,"\\wideonly[ ]*(%b{})","QQQ%1ZZZ")
    line=string.gsub(line,"\\htmlonly[ ]*(%b{})","QQQ%1ZZZ")
    line=string.gsub(line,"\\checked%b{}%b{}","")
    line=string.gsub(line,"\\LeadFrom%b{}%b{}%b{}","")
    line=string.gsub(line,"\\narrowonly%b{}","")
    line=string.gsub(line,"\\nothtml%b{}","")
    line=string.gsub(line,"\\AliasQuestion%b{}","")
    line=string.gsub(line,"%-{}%-{}%-","---")
    line=string.gsub(line,"\\hyperflat(%b{})%b{}","QQQ%1ZZZ")
    line=string.gsub(line,"\\latexhtml%b{}(%b{})","QQQ%1ZZZ") -- need to unquote &

    line=string.gsub(line,"\\htmlentity{([^{}]*)}","&%1;")

    line=string.gsub(line,"\\CTANhref%{faq}%b{}","<a href=\"http://www.ctan.org/pkg/uk-tex-faq\">FAQ's CTAN directory</a>")
    line=string.gsub(line,"\\CTANhref%{cat%-licences}%b{}","<a href=\"http://www.ctan.org/license/\">list of licences</a>")
    line=string.gsub(line,"\\CTANhref%{faq%-a4%}%b{}","<a href=\"http://www.ctan.org/tex-archive/help/uk-tex-faq/newfaq.pdf\">A4 paper</a>")
    line=string.gsub(line,"\\CTANhref{faq%-letter}%b{}","<a href=\"http://www.ctan.org/tex-archive/help/uk-tex-faq/letterfaq.pdf\">North American &ldquo;letter&rdquo; paper</a>")
    line=string.gsub(line,"\\CTANhref{visualFAQ}%b{}","<a href=\"http://www.ctan.org/tex-archive/info/visualFAQ/visualFAQ.pdf\">Visual FAQ</a>")


    line=string.gsub(line,"\\Email[ ]*(%b{})","<a href=\"mailto:QQQ%1ZZZ\">QQQ%1ZZZ</a>")-- hmm
    line=string.gsub(line,"\\mailto[ ]*(%b{})","<a href=\"mailto:QQQ%1ZZZ\">QQQ%1ZZZ</a>")-- hmm
    line=string.gsub(line,"\\URL[ ]*(%b{})","[QQQ%1ZZZ]")-- hmm
    line=string.gsub(line,"\\url[ ]*(%b{})","[QQQ%1ZZZ]")
    line=string.gsub(line,"\\href[%* ]*(%b{})(%b{})","[QQQ%2ZZZ](QQQ%1ZZZ)")
    line=string.gsub(line,"\\Qref[*]?(%[\\htmlonly%])(%b{})(%b{})","[QQQ%2ZZZ](FAQQQ%3ZZZ.html)")
    line=string.gsub(line,"\\Qref[*]?(%b[])(%b{})(%b{})","[QQQ%2ZZZ](FAQQQ%3ZZZ.html)")
    line=string.gsub(line,"\\Qref[*]?(%b{})(%b{})","[QQQ%1ZZZ](./FAQQQ%2ZZZ.html)")
    if string.match(line,"\\CTANref") then line = "" end 

    line=string.gsub(line,"\\includegraphics[ ]*{([^{}]*%.png)}","<img alt=\"%1\" src=\"%1\">")

    line=string.gsub(line,"\\begin{tabular}%b{}","<table><tbody>")
    line=string.gsub(line,"\\end{tabular}","</tbody></table>")
    line=string.gsub(line,"\\tbhline","")
    line=string.gsub(line,"\\tbamp","</td><td>")
    line=string.gsub(line,"^(.*)\\tbeol","<tr><td>%1</td></tr>")


    line=string.gsub(line,"\\begin{quote}","")
    line=string.gsub(line,"\\end{quote}","")

    if (string.match(line,"\\begin{ctanrefs}")) then
      line=string.gsub(line,"\\begin{ctanrefs}","")
      ctanrefs=true
    end
    if (string.match(line,"\\end{ctanrefs}")) then
      line=string.gsub(line,"\\end{ctanrefs}","")
      ctanrefs=false
    end
    if(ctanrefs and string.match(line,"\\item")) then
      line = ""
    end


    if (string.match(line,"\\begin{description}") or
        string.match(line,"\\begin{booklist}") ) then
      line=string.gsub(line,"\\begin%b{}","\n")
      description=true
    end
    if (string.match(line,"\\end{description}") or
        string.match(line,"\\end{booklist}") ) then
      line=string.gsub(line,"\\end%b{}","\n")
      description=false
    end
    if(description and string.match(line,"\\item")) then
      line=string.gsub(line,"\\item[ ]*(%b[])","- QQQ%1ZZZ")
    end

    if string.match(line,"\\begin{itemize}") then
      itemize = true
      line = "\n"
    end
    if string.match(line,"\\begin{enumerate}") then
      enumerate = true
      enumitem = 0
      line = "\n"
    end
    if string.match(line,"\\end{itemize}") then
      itemize = false
      line = "\n"
    end
    if string.match(line,"\\end{enumerate}") then
      enumerate = false
      line = "\n"
    end

    if string.match(line,"\\item") then
      if enumerate then
        enumitem = enumitem + 1
        line = string.gsub(line,"\\item",enumitem .. ". ")
      else
        line = string.gsub(line,"\\item","- ")
      end
    elseif itemize or enumerate then
      line = "  " .. line
    end

    line=string.gsub(line,"[ ]*\\begin{footnoteenv}","<sup class=\"fmk\">&dagger;</sup><span class=\"footnote\">&dagger; ")
    line=string.gsub(line,"\\end{footnoteenv}","</span>")

    if (string.match(line,"\\begin{narrowversion}")) then
      line=""
      skipline=true
    end
    if (string.match(line,"\\end{narrowversion}")) then
      line=""
      skipline=false
    end

    if (string.match(line,"\\begin{typesetversion}")
        or string.match(line,"\\begin{pdfversion}")
        or string.match(line,"\\begin{dviversion}")
        or string.match(line,"\\htmlignore")
	or string.match(line,"\\begin{flatversion}")) then
      line=""
      skipline=true
    end
    if (string.match(line,"\\end{typesetversion}")
        or string.match(line,"\\end{pdfversion}")
        or string.match(line,"\\end{dviversion}")
        or string.match(line,"\\endhtmlignore")
	or string.match(line,"\\end{flatversion}")) then
      line=""
      skipline=false
    end


    if (skipline) then
      line=""
    end

      line=string.gsub(line,"\\begin{wideversion}","")
      line=string.gsub(line,"\\end{wideversion}","")


      line=string.gsub(line,"\\begin{htmlversion}","") -- need to unquote &
      line=string.gsub(line,"\\end{htmlversion}","")

      line=string.gsub(line,"\\begin{hyperversion}","") 
      line=string.gsub(line,"\\end{hyperversion}","")


    if string.match(line, "\\LastEdit[%* ]*{([^{}]*)}") then
      line = ""
    end


    line=string.gsub(line,"QQQ.","")
    line=string.gsub(line,".ZZZ","")
-- last minute fixups
line=string.gsub(line,"(<a[^<>]*href=[^<>]*)&nbsp;","%1~")
line=string.gsub(line,"(<a[^<>]*href=\"FAQ[^<>]*)%*","%1star")
line=string.gsub(line,"p{([0-9])cm}","p&#x7b;%1cm&#x7d;")
line=string.gsub(line,"\\label{lastquestion}","")
line=string.gsub(line,"(<code>[^<]*)\\","%1&#x5c;")
line=string.gsub(line,"\\_","_")
line=string.gsub(line,"\\#","#")
line=string.gsub(line,"\\@","")

-- check for TeX markup surviving
    line=string.gsub(line,"[^`]\\(%a+)[^`]","[[[%1]]]")
    line=string.gsub(line,"[^`]\\([^%a])[^`]","[[[%1]]]")
    
-- Cleanup some odd markup
  line = string.gsub(line,"''`","`")
  line = string.gsub(line,"'`","`")
  line = string.gsub(line,"`''","`")
  line = string.gsub(line,"`'","`")
  
return line
end

function file_to_toc(file)
  local line
  for line in io.lines(file) do

    if(string.match(line,"^[ ]*\\begin{verbatim}") or
        string.match(line,"^[ ]*\\begin{introduction}")
	) then
      tocverb=true
    end
    if(string.match(line,"^[ ]*\\end{verbatim}")or
        string.match(line,"^[ ]*\\end{introduction}")
	) then
      tocverb=false
    end

    if(not(tocverb) and string.match(line,"^[ ]*\\section{")) then
      section=faq_convert_line((string.gsub(line,".*\\section{(.*)} *$","%1")))
      secid=string.gsub(section,"[^%a]","")
      if(lastlevel==0) then
        io.write("<ul>\n")
      end
--[[ not right
      if(lastlevel==1) then
        io.write("  </li>\n")
      end
      if(lastlevel==2) then
        io.write("  </li></ul></li>\n")
      end
      if(lastlevel==3) then
        io.write("  </li></ul></li></ul></li>\n")
      end
--]]
      io.write("  <li class=\"tocsec\" id=\"" .. secid .. "\"><span>" .. section .. "</span>\n")
      lastlevel=1
    end

    if(not(tocverb) and string.match(line,"^[ ]*\\subsection{")) then
      subsection=faq_convert_line((string.gsub(line,".*\\subsection{(.*)} *$","%1")))
      subsecid=string.gsub(subsection,"[^%a]","")
--[[ not right
      if(lastlevel==1) then
        io.write("  <ul>\n")
      end
      if(lastlevel==2) then
        io.write("  </li>\n")
      end
--]]
     io.write("    <li class=\"tocsubsec\" id=\"" .. subsecid .. "\"><span>" .. subsection .. "</span>\n")
     lastlevel=2
    end

    if(string.match(line,"^[ ]*\\Question%[")) then
      qid=string.gsub(line,".*\\Question%[([^%]]*)]{(.*)} *$","%1")
      qid=string.gsub(qid,"%*","star")
      qtitle=faq_convert_line((string.gsub(line,".*\\Question%[([^%]]*)]{(.*)} *$","%2")))
--[[ not right
      if(lastlevel==1) then
        io.write("  <ul>\n")
      end
      if(lastlevel==2) then
        io.write("  <ul>\n")
      end
      if(lastlevel==3) then
        io.write("  </li>\n")
      end
--]]
      io.write("      <li class=\"tocqn\" id=\"" .. qid .. "\"><a href=\"FA" .. qid .. ".html\">" .. qtitle .. "</a></li>\n")
      lastlevel=3
    end
  end
end


function faq_make_toc ()
  local line
  lastlevel=0
  io.write("\n<div class=\"toc\">\n")
  for line in io.lines("gather-faqbody.tex") do
    if(string.match(line,"\\faqinput{")) then
      tocfile=string.gsub(line,"^.*\\faqinput{(.*)}.*$","%1.tex")
      file_to_toc(tocfile)
    end
  end
  io.write("\n</div>\n")
end


for line in io.lines("gather-faqbody.tex") do
  if(string.match(line,"\\faqinput{")) then
    file=string.gsub(line,"^.*\\faqinput{(.*)}.*$","%1.tex")
    file_to_md(file)
  end
end


