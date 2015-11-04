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
    %   fontsize    - Font size in pt. Default: 11.
    %   textwidth   - Textwidth of your LaTeX page in cm. Default: 17.
    %   format      - Must be supported by `print`. Default: 'pdf'.
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
    aspectratio = 5/3; % width/height
    figwidth = 0.8; % *textwidth
    fontsize = 11; % pt
    textwidth = 17; % cm
    format = 'pdf';
    
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
            case 'form'
                format = varargin{i+1};
        end
    end
   
    [pathstr, name] = fileparts(filename);
    if escape
        name = regexprep(name, ' ', '_');
        name = regexprep(name, '~', '_');
    end
    
    set(fig, 'PaperUnits', 'centimeters');
    set(fig, 'PaperSize', [textwidth, textwidth/aspectratio].*figwidth);
    set(fig, 'PaperPosition', [0, 0, [textwidth, textwidth/aspectratio].*figwidth]);
    
    old_units = fig.Units;
    old_pos = fig.Position;
    
    fig.Units = 'centimeters';
    fig.Position = [fig.Position(1:2) textwidth, textwidth/aspectratio].*figwidth;
    
    % Font options:
    if texify
        o = {'interpreter', 'latex', 'FontSize', fontsize};
        ticko = {'TickLabelInterpreter', 'latex', 'FontSize', fontsize-2};
        legendo = {'interpreter', 'latex', 'FontSize', fontsize-2};
    else
        o = {'FontSize', fontsize};
        ticko = {'FontSize', fontsize-2};
        legendo = {'FontSize', fontsize-2};
    end
    
    children = fig.Children;
    for i = 1:length(children)
        if isa(children(i), 'matlab.graphics.axis.Axes')
            set(get(children(i), 'XLabel'), o{:});
            set(get(children(i), 'YLabel'), o{:});
            set(get(children(i), 'ZLabel'), o{:});

            set(children(i), ticko{:});
            op = get(children(i), 'outerPosition');
            old_op(i, :) = op;
            ax(i) = children(i);
            if op(2) < 0
                op(2) = 0.01;
            end
            if op(4) > 1
                op(4) = 1;
            end
            set(children(i), 'outerPosition', op);
        end
        if isa(children(i), 'matlab.graphics.illustration.Legend')
            set(children(i), legendo{:})
        end            
    end
    
    print(fig, ['-d' format], '-r600', fullfile(pathstr, name))
    fig.Units = old_units;
    fig.Position = old_pos;
    for i = 1:length(ax)
        ax(i).OuterPosition = old_op(i, :);
    end
end
