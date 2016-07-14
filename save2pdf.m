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
    %   tick_fontsize - Font size in pt. Default: 9.
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
    
	% turn off warnings:
	warning('off', 'MATLAB:handle_graphics:exceptions:SceneNode')
	warning('off', 'MATLAB:copyobj:ObjectNotCopied')
	
    % set defaults:
    escape = true;
    texify = true;
    fig = gcf;
    aspectratio = 5/3; % width/height
    figwidth = 0.8; % *textwidth
    fontsize = 11; % pt
    tick_fontsize = fontsize-2; % pt
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
                tick_fontsize = fontsize-2;
            case 'text'
                textwidth = varargin{i+1};
            case 'form'
                format = varargin{i+1};
            case 'tick'
                tick_fontsize = varargin{i+1};
        end
    end
    
    % copy figure before making any changes
    n_fig = figure('visible', 'off');
    % find all children of fig that are not menus and toolbars and stuff
    cs = allchild(fig);
    cs = cs(10:end);
    
    copyobj(cs, n_fig);
    fig = n_fig;
    
    [pathstr, name] = fileparts(filename);
    if escape
        name = regexprep(name, ' ', '_');
        name = regexprep(name, '~', '_');
    end
    
    set(fig, 'PaperUnits', 'centimeters');
    set(fig, 'PaperSize', [textwidth, textwidth/aspectratio].*figwidth);
    set(fig, 'PaperPosition', [0, 0, [textwidth, textwidth/aspectratio].*figwidth]);

    fig.Units = 'centimeters';
    fig.Position = [fig.Position(1:2) textwidth, textwidth/aspectratio].*figwidth;
    
    % Font options:
    if texify
        o = {'interpreter', 'latex', 'FontSize', fontsize};
        ticko = {'TickLabelInterpreter', 'latex', 'FontSize', tick_fontsize};
        legendo = {'interpreter', 'latex', 'FontSize', tick_fontsize};
    else
        o = {'FontSize', fontsize};
        ticko = {'FontSize', tick_fontsize};
        legendo = {'FontSize', tick_fontsize};
    end    

    children = fig.Children;
    
    tick_fontsize
    
    for i = 1:length(children)
        if isa(children(i), 'matlab.graphics.axis.Axes')   
                  
            children(i).FontSize = tick_fontsize;
            
            
            children(i).XLabel.FontSize = fontsize;
            children(i).YLabel.FontSize = fontsize;
            children(i).ZLabel.FontSize = fontsize;            
            
            if texify
                children(i).XLabel.Interpreter = 'latex';
                children(i).YLabel.Interpreter = 'latex';
                children(i).ZLabel.Interpreter = 'latex';
                children(i).TickLabelInterpreter = 'latex';
            end

            
%             set(children(i), ticko{:});
            op = get(children(i), 'outerPosition');
            if op(2) < 0
                ax(i) = children(i);
                op(2) = 0.01;
            end
            if op(4) > 1
                ax(i) = children(i);
                op(4) = 1;
            end
            set(children(i), 'outerPosition', op);
        end
        if isa(children(i), 'matlab.graphics.illustration.Legend')
            set(children(i), legendo{:})
        end            
        if isa(children(i), 'matlab.graphics.illustration.ColorBar')
            set(children(i), 'TickLabelInterpreter', 'latex')
            set(children(i), 'FontSize', tick_fontsize)
        end
    end
    
    % save the file
    print(fig, ['-d' format], '-r600', fullfile(pathstr, name))
    
    % clean up
    fig.delete();
	
	% turn on warnings:
	warning('on', 'MATLAB:handle_graphics:exceptions:SceneNode')
	warning('on', 'MATLAB:copyobj:ObjectNotCopied')
end
