\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{umnthesis}[2019/08/28 UMN Graduate School Thesis]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DOCUMENT CLASS OPTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\RequirePackage{kvoptions}
\RequirePackage{xparse}

% Macro to generate complemantary class options with names `x` and no`x` which
% have opposite meanings. Defaults to `x` = true.
\NewDocumentCommand{\DeclareBoolOptionPair}{ O{true} m }{%
  \DeclareBoolOption[#1]{#2}%
  \DeclareComplementaryOption{no#2}{#2}%
}

% Enables use of glossaries
% TODO: Make the glossary package options customizable
\DeclareBoolOptionPair[false]{glossary}

% Add line numbers in draft mode. Defaults to false, but defined as package
% option since some patching is required to make numbering work with amsmath.
\DeclareBoolOptionPair[false]{linenumbers}

% Support disabling certain features; useful for, e.g., standalone/preview
% picture environments which will inherit many settings but don't need full
% document functionality.
\DeclareBoolOptionPair{bib}         % Whether a bibliography is generated
\DeclareBoolOptionPair{fonts}       % Default font handling may be disabled
\DeclareBoolOptionPair{frontmatter} % Whether to typset the frontmatter
\DeclareBoolOptionPair{hyperref}    % Whether to load and use hyperref

\ProcessKeyvalOptions*

% Base the entire document off report since it already provides chapters.
% The U of M thesis also has margin requirements that are easiest to match in
% one-sided mode.
\LoadClassWithOptions{report}

% Generate a hook that can be used to delay code until after the front
% matter has been typeset.
\def\umnthesis@frontmatterhook{}\relax
\def\AfterEndFrontmatter{\g@addto@macro\umnthesis@frontmatterhook}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LATEX SETUP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load some packages and create settings which will be assumed to exist from
% here on out for their great utility:
  \RequirePackage{etoolbox}
  \RequirePackage{xpatch}
  \RequirePackage{ifdraft}

% We will always assume at the very least the pdfLaTeX is in use. To permit
% possible specialization for XeLaTex and LuaLaTeX, create a new boolean that
% identifies these advanced engines simultaneously.
  \RequirePackage{ifxetex}
  \RequirePackage{ifluatex}
  \newif\ifxeluatex
  \ifxetex
    \xeluatextrue
  \else
    \ifluatex
      \xeluatextrue
    \else
      \xeluatexfalse
    \fi
  \fi

% Handle Unicode intelligently.
  % For XeLaTeX and LuaLaTeX, nothing fancy should be required
  \ifxeluatex
    \relax

  % For pdfLaTeX, setup the input encoding.
  \else
    \RequirePackage[utf8]{inputenc}
  \fi


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DEFAULT PACKAGES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Inclusion of figures should always happen via graphicx
  \RequirePackage[final]{graphicx}

% Provide nicer table handling by default
  \RequirePackage{tabularx}
  \RequirePackage{booktabs}

% Improve captions on both figures and tables
  \RequirePackage[
    font=footnotesize,
    labelfont=bf
  ]{caption}

% Have List of Figures, List of Tables, and Bibliography show up in the
% Table of Contents.
  \RequirePackage[nottoc]{tocbibind}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% U OF M FORMATTING REQUIREMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%
%% MARGINS

% Left is 1.5in, others are 1in.
  \RequirePackage{geometry}
  \geometry{
    paper = letterpaper, % Use US letter paper
    includeheadfoot,     % Nothing can appear in the margins, so force
                         % all content to live within the body.
    margin = 1.0in,      % Set margins to 1.0in,
    left   = 1.5in,      % and then override for left only.
  }

%%%%%%%%%
%% FONTS
\ifumnthesis@fonts

  \ifxeluatex
    \RequirePackage[no-math]{fontspec}
  \else
    % Use Type1 fonts.
    \RequirePackage[T1]{fontenc}
  \fi

% The choice of fonts is highly restrictive:
%
% The only acceptable serif font is Times New Roman, and sans-serif must be
% either Helvetica or Arial. STIX provides Times-compatible text font and a
% matching math font.
  \RequirePackage{stix}
  \RequirePackage[scaled=0.92]{helvet}
  \RequirePackage{courier}

% The author's opinion is that the STIX summation symbol is highly inferior
% to those in Computer Modern/Latin Modern. Use CM since it provides a symbol
% which is slightly larger than LM, and therefore matches the rest of STIX a
% bit better.

  % Load Computer Modern into the math font tables
  \DeclareSymbolFont{cmlargesymbols}{OMX}{cmex}{m}{n}
  % Map the summation operator into the LM font
  \DeclareMathSymbol{\sumop}{\mathop}{cmlargesymbols}{"50}

% Similarly, the \ell (small script L) character in STIX has the beginning
% of the loop far to high up the character (nearly half-way). CM's looks
% quite a bit better, but it is slightly too light compared to STIX. The
% glyph in Palatino, though, is a reasonable compromize.

  % Small Script L substitution:
  %     Loads Palatino and assigns \ell to use it instead.
  \DeclareSymbolFont{plletters}{OML}{zplm}{m}{it}
  \DeclareMathSymbol{\ell}{\mathalpha}{plletters}{"60}

\fi

% Some manual kerning corrections:
  % The subscript on \nabla should be kerned a bit more tightly.
  \let\OldNabla\nabla
  \RenewDocumentCommand{\nabla}{e_}{%
    \OldNabla\IfValueT{#1}{_{\!#1}}%
  }

% Patch \bfseries to also switch math into bold mode. This is really useful
% for situations like having math in a section heading which may or may not
% be bolded.
  \xapptocmd{\bfseries}{\boldmath}{}{}

%%%%%%%%%%%
%% SPACING

% Only double or 1.5 spacing are permitted. The setspace package defines the
% spacings more compactly than i.e. Word does, so go with double spacing by
% default.
  \RequirePackage{setspace}
  \doublespacing
  \AtEndPreamble{%
    % Typeset display math in single spacing mode, though. This is particularly
    % important when writing out matrices.
    \everydisplay=\expandafter{%
      \the\everydisplay\def\baselinestretch{1}\selectfont%
    }%
    \everymath=\expandafter{%
      \the\everymath\def\baselinestretch{1}\selectfont%
    }%
  }

%%%%%%%%%%%%%%
%% PAGINATION

% Pages must use Arabic numerals. This will be setup after typesetting the
% front matter.

% In addition to the standard \title and \author commands, we need to have
% \institution, \advisor, \month, and \year commands for various bits of
% information needed on the title page.
  \global\let\umnthesis@institution\@empty
  \global\let\umnthesis@advisor\@empty
  \global\let\umnthesis@month\@empty
  \global\let\umnthesis@year\@empty
  \newcommand{\institution}[1]{\gdef\umnthesis@institution{#1}}
  \newcommand{\thesisadvisor}[1]{\gdef\umnthesis@advisor{#1}}
  \newcommand{\thesismonth}[1]{\gdef\umnthesis@month{#1}}
  \newcommand{\thesisyear}[1]{\gdef\umnthesis@year{#1}}
  % Furthermore, undefine \date since we won't allow it to prevent mistakes.
  \let\date\@undefined
  \let\@date\@undefined

% Use "Table of Contents" instead of "Contents"
  \renewcommand{\contentsname}{Table of Contents}
% Also provide redefinable macros setting the Abstract, Acknowledgments, and
% Dedication pages as well.
  \providecommand{\abstractname}{Abstract}
  \providecommand{\acknowledgmentsname}{Acknowledgments}
  \providecommand{\dedicationname}{Dedication}

% Redefine the abstract command to hold its argument for printing in the
% front matter.
  \DeclareRobustCommand{\abstract}[1]{\gdef\@abstract{#1}}
  \newcommand{\printabstract}{%
    \ifdef{\@abstract}{%
      \chapter*{\abstractname}%
      \@abstract%
    }{
      \ClassError{umnthesis}{%
        An abstract is not optional.\MessageBreak%
        \MessageBreak%
        Add an abstract by writing \protect\abstract{<text>} in your\MessageBreak%
        document preamble%
      }
    }
  }

% Then make similar macros to provide optional Acknowledgments and
% Dedication sections.
%
%   These are both optional, though, so print nothing if the internal text
%   macro is undefined (signalling that the author didn't call it).

  \DeclareRobustCommand{\acknowledgments}[1]{\gdef\@acknowledgments{#1}}
  \newcommand{\printacknowledgments}{%
    \ifdef{\@acknowledgments}{%
      \chapter*{\acknowledgmentsname}%
      \@acknowledgments%
      \clearpage%
    }{%
      \relax%
    }
  }
  \DeclareRobustCommand{\dedication}[1]{\gdef\@dedication{#1}}
  \newcommand{\printdedication}{%
    \ifdef{\@dedication}{%
      \chapter*{\dedicationname}%
      \@dedication%
      \clearpage%
    }{%
      \relax%
    }
  }

%%%%%%%%%%%%%%%%
%% BIBLIOGRAPHY

% Few restrictions are placed on the bibliography, so just load biblatex with
% biber enabled by default. Then let the user control any further settings.

  \ifumnthesis@bib
    \RequirePackage[
        backend=biber,
        citestyle=numeric-comp,
      ]{biblatex}[2018/02/20]
  \fi
  % Note that the tocbibind package can't automatically add the bibliography
  % heading to the Table of Contents after loading this, so you should
  % print out the bibliography using
  %
  %   \printbibliography[heading=bibintoc]
  %
  % to achieve that.

%%%%%%%%%%%%
%% GLOSSARY

\ifumnthesis@glossary
  % glossaries must be loaded after hyperref. Since hyperref will push itself
  % onto the top of the AtEndPreamble stack, we can just append to the end
  % and still have operations execute in the correct order.
  \AtEndPreamble{%
    \RequirePackage[
        xindy,
        toc,
        nopostdot,
        section=chapter,
        numberedsection=autolabel
    ]{glossaries}
    \makeglossaries
  }
\fi

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OPTIONAL FORMATTING CHANGES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Use microtype enhancements to make the visual appearance as nice as possible.
  \RequirePackage[final]{microtype}

% Patch \bfseries to also switch math into bold mode. This is really useful
% for situations like having math in a section heading which may or may not
% be bolded.
  \xapptocmd{\bfseries}{\boldmath}{}{}


% In draft mode, enable line numbers on all lines. This aids in receiving
% feedback.
\ifumnthesis@linenumbers
  \ifdraft{%
    \RequirePackage[switch*]{lineno}
    % The AMS math environments don't interact well with the line numbering
    % by default, so patch those up if necessary.
    %
    % Solution adapted from https://tex.stackexchange.com/a/55297
    \newcommand*\patchAmsMathEnvironmentForLineno[1]{%
      \expandafter\let\csname old#1\expandafter\endcsname\csname #1\endcsname
      \expandafter\let\csname oldend#1\expandafter\endcsname\csname end#1\endcsname
      \renewenvironment{#1}%
         {\linenomath\csname old#1\endcsname}%
         {\csname oldend#1\endcsname\endlinenomath}%
    }%
    \newcommand*\patchBothAmsMathEnvironmentsForLineno[1]{%
      \patchAmsMathEnvironmentForLineno{#1}%
      \patchAmsMathEnvironmentForLineno{#1*}%
    }%
    \AtBeginDocument{%
      \linenumbers%
      \@ifpackageloaded{amsmath}{%
        \patchBothAmsMathEnvironmentsForLineno{equation}%
        \patchBothAmsMathEnvironmentsForLineno{align}%
        \patchBothAmsMathEnvironmentsForLineno{flalign}%
        \patchBothAmsMathEnvironmentsForLineno{alignat}%
        \patchBothAmsMathEnvironmentsForLineno{gather}%
        \patchBothAmsMathEnvironmentsForLineno{multline}%
      }{}% \@ifpackageloaded
    }%
  }{}% \ifdraft
\fi


% Use PDF hyperlinks. Load this at the end of the preamble as required by the
% hyperref documentation.
%
% IMPORTANT NOTE!
%   It took much debugging to figure out that biblatex makes use of the
%   \AtEndPreamble command to finalize much of its setup, especially with
%   respect to knowing if hyperref has been loaded or not. For this reason,
%   loading hyperref with \AtEndPreamble as well *after* we've already loaded
%   biblatex means the the code below is executed after code that biblatex
%   has loaded into the hook.
%
%   To get around this, we can instead *prepend* our code to the hook that
%   \AtEndPreamble normally appends to. We do this by patching a copy of the
%   command to use \gpreto instead of \gappto.
%
  \let\PreAtEndPreamble\AtEndPreamble%
  \patchcmd{\PreAtEndPreamble}{\gappto}{\gpreto}{}{%
    \ClassError{umnthesis}{%
      Prepending to the \verb|\AtEndPreamble| hook failed. Could not setup
      hyperref correctly.
    }{%
      Loading hyperref is a tricky business, and our attempt to have hyperref
      load at the correct time when also using biblatex failed. A guess would
      be that the format of the \verb|\AtEndPreamble| command has changed,
      which means our attempt to patch a copy for our purposes has failed.
      \MessageBreak\MessageBreak
      See comments in the source for umnthesis.cls for more information.
    }
  }
  \ifumnthesis@hyperref
    \PreAtEndPreamble{%
      \RequirePackage[draft=false,unicode]{hyperref}%
      \@ifclassloaded{standalone}{}{%
        \RequirePackage[all]{hypcap}%
      }
    }
    \AtEndPreamble{%
      % For some reason, the following commands do not seem to work if added to
      % the package options, so we pass them via the hypersetup command instead.
      \hypersetup{
        % The following two options create colored underlines for links when
        % viewed with a PDF reader on screen, but do not apply to a printed
        % document.
        ,pdfborderstyle = {/S/U/W 1}%
        ,ocgcolorlinks  = true%
        % With on-screen indicators, disable colors in the printed form.
        ,colorlinks     = false%
        % Include some metadata
        ,pdfauthor      = {\@author}%
        ,pdftitle       = {\@title}%
      }%
    }
  \fi % \ifumnthesis@hyperref


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MISCELLANEOUS FORMATTING FIXES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Fix frame boundaries drawn by geometry in the context of landscape pages
  % from lscape and pdflscape.
  %
  % Solution taken from
  %     https://tex.stackexchange.com/a/116521
  \PreAtEndPreamble{%
    % pdflscape loads lscape, so we can get away with just checking for the
    % latter.
    \@ifpackageloaded{lscape}{%
      \newcommand*{\gmshow@textheight}{\textheight}
      \newdimen\gmshow@@textheight%
      \g@addto@macro\landscape{%
        \gmshow@@textheight=\hsize%
        \renewcommand*{\gmshow@textheight}{\gmshow@@textheight}%
      }%
      \def\Gm@vrule{%
        \vrule width 0.2pt height\gmshow@textheight depth\z@%
      }%
    }{}% \@ifclassloaded
  } % \PreAtEndPreamble

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DOCUMENT SETUP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% At the beginning of the document, automatically handle creating the front
% matter based on various settings that must be set within the preamble.

\ifumnthesis@frontmatter
  % Note that we use \AfterEndPreamble rather than \AtDocumentBegin. There is a
  % difference, and using the latter causes the PDF page numbers to become out
  % of sync with the LaTeX page numbers. See etoolbox documentation for details
  % on how the two commands differ.
  \AfterEndPreamble{%
    % Remove all space that may be reserved for a header and footer on the
    % title and copyright pages.
    \newgeometry{%
      margin = 1in,%
      left = 1.5in,%
      noheadfoot,%
      ignoreheadfoot%
    }%
    % Also "number" them using latin letters. This only effects the PDF page
    % numbering since we won't be printing them onto the page.
    \pagenumbering{alph}%
    %%%%%%%%%%%%
    %% TITLE PAGE
    \begingroup%
      \pagestyle{empty}
      \hbox{}
       %Everything is centered and larger than the body text
      \centering\large%
      % Title first
      \par\vfill
      {
        \Large
        \MakeUppercase{\@title}%
      }
      \par\vfill
      {
        A DISSERTATION\\
        SUBMITTED TO THE FACULTY OF THE\\
        \MakeUppercase{\umnthesis@institution}\\
        BY
      }
      \par\vfill
      {
        \Large
        \MakeUppercase{\@author}
      }
      \par\vfill
      {
        IN PARTIAL FULFILLMENT OF THE REQUIREMENTS\\
        FOR THE DEGREE OF\\
        DOCTOR OF PHILOSOPHY
      }
      \par\vfill
      {
        \MakeUppercase{\umnthesis@advisor}\\
        \MakeUppercase{\umnthesis@month}~\MakeUppercase{\umnthesis@year}
      }
      \clearpage
    \endgroup%
    %%%%%%%%%%%%%%%%
    %% COPYRIGHT PAGE
    \begingroup%
      \pagestyle{empty}%
      % Use normal size text, but still centered
      \normalsize%
      \centering%
      % Vertically center the content
      \null\vfill
      \copyright~\MakeUppercase{\@author}~\umnthesis@year\\
      ALL RIGHTS RESERVED
      \vfill
      \clearpage
    \endgroup
    \restoregeometry
    % Now switch to roman numeral numbering for the rest of the front matter,
    % and start it's numbering at 1.
    \setcounter{page}{1}
    \pagenumbering{roman}%
    %%%%%%%%%%%%%%%%%
    %% OPTIONAL ACKNOWLEDGMENTS AND DEDICATION PAGES
    %%   \clearpage is handled by print macros, so none here
    \printacknowledgments
    \printdedication
    %%%%%%%%%%%%%%%%%
    %% ABSTRACT PAGE
    \printabstract
    \clearpage
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% TABLE OF CONTENTS PAGES
    \ifumnthesis@hyperref
      \currentpdfbookmark{\contentsname}{contents}
    \fi
    \tableofcontents
    \clearpage
    %%%%%%%%%%%%%%%%%%%
    %% LIST OF FIGURES
    \listoffigures
    \clearpage
    %%%%%%%%%%%%%%%%%%
    %% LIST OF TABLES
    \listoftables
    \clearpage
    %%%%%%%%%%%%%%%%%
    %% DOCUMENT BODY
    % In twoside mode, make sure we skip another page if necessary
    \if@twoside
      \ifodd\c@page
      \else
        \hbox{}
        \clearpage
      \fi
    \fi
    % Finally, reset the counter again to 1 and print in arabic numbers.
    \setcounter{page}{1}
    \pagenumbering{arabic}
  }
\fi % \ifumnthesis@frontmatter

\AfterEndPreamble{%
  \ifdefined\umnthesis@frontmatterhook
    \umnthesis@frontmatterhook
  \fi
}

% vim: set syntax=tex sw=2 sts=2 ts=2 et:
