function [ ] = save2pdf( filename, varargin )
    %SAVE2PDF: Saves figure to pdf.
    %
    % save2pdf( filename, options )
    %
    % Saves a figure to a pdf in a nice size and with texed text.
    % 
    % filename    - Path (absolute or relative to the current working dir).
    %
    % varargin:
    %   width       - Adjusts font sizes so that they are readable with
    %                 different figure widths for a4paper. Default: 0.8*\textwidth.
    %   aspectratio - Aspect ratio. Defaults to height/width = 3/5.
    %   figure     - Figure to save. Default: Current figure.
    %   texify      - Texify the labels and legends. Default: true.
    %   escape      - escapes ' ' and '~', which cannot be parsed by LaTeX.
    %                 Default: true.
    %   fontsize    - Font size in pt. Defaults to 11.
    %   textwidth   - Textwidth of your LaTeX page in cm. Default: 17.
    %
    % Example:   plot(1:10);
    %            xlabel('bla');
    %            legend({'curve 1'});
    %            save2pdf('plot', 'width', 0.8)
    %
    % Author:    Sebastian Pfitzner
    %            pfitzseb [at] physik . hu - berlin . de
       
    % check inputs
    if strcmp(filename, '')
        error('Please supply a filename.')
    end
    
    if mod(length(varargin), 2) ~= 0 
        error('Wrong number of arguments.');
    end
    
    % set defaults:
    escape = true;
    texify = true;
    fig = gcf;
    aspectratio = 3/5; % height/width
    figwidth = 0.8; % *textwidth
    fontsize = 11; % pt
    textwidth = 17; % cm

    % user-supplied options:
    for i = 1:2:length(varargin)
        switch lower(varargin{i}(1:4))
            case 'esca'
                escape = varargin{i+1};
            case 'texi'
                texify = varargin{i+1};        
            case 'figu'
                fig = varargin{i+1};
            case 'aspe'
                aspectratio = varargin{i+1};
            case 'widt'
                figwidth = varargin{i+1};
            case 'font'
                fontsize = varargin{i+1};
            case 'text'
                textwidth = varargin{i+1};
        end
    end
   
    [pathstr, name] = fileparts(filename);
    if escape
        name = regexprep(name, ' ', '_');
        name = regexprep(name, '~', '_');
    end
    
    set(fig, 'PaperUnits', 'centimeters');
    set(fig, 'PaperSize', [textwidth, textwidth*aspectratio].*figwidth);
    set(fig, 'PaperPosition', [0, 0, [textwidth, textwidth*aspectratio].*figwidth]);
    
    % Font options:
    if texify
        o = {'interpreter', 'latex', 'FontSize', fontsize};
        ticko = {'TickLabelInterpreter', 'latex', 'FontSize', fontsize};
        legendo = {'interpreter', 'latex', 'FontSize', fontsize-2};
    else
        o = {'FontSize', fontsize};
        ticko = {'FontSize', fontsize};
        legendo = {'FontSize', fontsize-2};
    end
    
    children = fig.Children;
    for i = 1:length(children)
        if isa(children(i), 'matlab.graphics.axis.Axes')
            set(get(children(i), 'XLabel'), o{:});
            set(get(children(i), 'YLabel'), o{:});
            set(get(children(i), 'ZLabel'), o{:});

            set(children(i), ticko{:});
        end
        if isa(children(i), 'matlab.graphics.illustration.Legend')
            set(children(i), legendo{:})
        end            
    end

	if strcmp(pathstr, '')
		print(fig, '-dpdf', '-r600', [name '.pdf'])
	else
		print(fig, '-dpdf', '-r600', [pathstr '/' name '.pdf'])
	end
end
