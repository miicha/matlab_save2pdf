function [figdim] = save2pdf( filename, varargin )
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
    %   aspectratio - Aspect ratio. Defaults to width/height = 5/3.
    %   figure     - Figure to save. Default: Current figure.
    %   texify      - Texify the labels and legends. Default: true.
    %   escape      - escapes ' ' and '~' in file name, which cannot be parsed by LaTeX.
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
    keepAscpect = false;
    remClipping = false;
    figdim =[];
    tight = false;
    
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
            case 'keep'
                keepAscpect = varargin{i+1};
            case 'remo'
                remClipping = varargin{i+1};
            case 'fixs'
                figdim = varargin{i+1};
            case 'tigh'
                tight = varargin{i+1};
        end
    end
    
    % copy figure before making any changes
%     n_fig = figure('visible', 'off');
%     % find all children of fig that are not menus and toolbars and stuff
%     cs = allchild(fig);
%     cs = cs(10:end);
%     
%     copyobj(cs, n_fig);
%     fig = n_fig;
    
    [pathstr, name] = fileparts(filename);
    if escape
        name = regexprep(name, ' ', '_');
        name = regexprep(name, '~', '_');
    end
    
    set(fig, 'PaperUnits', 'centimeters');
    fig.Units = 'centimeter';
    
    if isempty(figdim)
        figdim = [textwidth, textwidth/aspectratio].*figwidth;
    end
    
%     fig.PaperSize =  figdim;
%     fig.PaperPosition= [0, 0, figdim];
%     fig.InnerPosition= [0, 0, figdim];
    
%     set(fig, 'PaperSize', figdim);
%     set(fig, 'PaperPosition', [0, 0, [textwidth, textwidth/aspectratio].*figwidth]);
    
    % Font options:
    if texify
        legendo = {'interpreter', 'latex', 'FontSize', tick_fontsize};
    else
        legendo = {'FontSize', tick_fontsize};
    end
    
    fig.PaperSize =  figdim;
    fig.PaperPosition= [0, 0, figdim];

    children = fig.Children;
    numchild = 0;
    for i = 1:length(children)
        if isa(children(i), 'matlab.graphics.axis.Axes')
            numchild = numchild+1;
            if texify
                children(i).TickLabelInterpreter = 'latex';
            end
            
            for j = 1:length(children(i).XAxis)
                children(i).XAxis(j).Label.FontSize = fontsize;
                if texify
                    if ~strcmp(children(i).XAxis(j).Label.Interpreter,'latex')
                        children(i).XAxis(j).Label.String = strrep(children(i).XAxis(j).Label.String, '\mu','$$\mu$$');
                        children(i).XAxis(j).Label.Interpreter = 'latex';
                    end
                end
            end
            for j = 1:length(children(i).YAxis)
                children(i).YAxis(j).Label.FontSize = fontsize;
                if texify
                    if ~strcmp(children(i).YAxis(j).Label.Interpreter,'latex')
                        children(i).YAxis(j).Label.String = strrep(children(i).YAxis(j).Label.String, '#','$$\#$$');
                        children(i).YAxis(j).Label.Interpreter = 'latex';
                    end
                end
            end
            for j = 1:length(children(i).XAxis)
                children(i).ZAxis(j).Label.FontSize = fontsize;
                if texify
                    children(i).ZAxis(j).Label.Interpreter = 'latex';
                end
            end
        end
        
        if isa(children(i), 'matlab.graphics.illustration.Legend')
            set(children(i), legendo{:})
        end
        if isa(children(i), 'matlab.graphics.illustration.ColorBar')
            if texify
                set(children(i), 'TickLabelInterpreter', 'latex')
            end
            set(children(i), 'FontSize', tick_fontsize)
        end
    end
    
    for i = 1:length(children)
        if isa(children(i), 'matlab.graphics.axis.Axes')
            ax = children(i);
            
            children(i).FontSize = tick_fontsize;
            children(i).ActivePositionProperty = 'OuterPosition'; % Beschriftung nicht abschneiden
            children(i).XLabel.FontSize = fontsize;
            children(i).YLabel.FontSize = fontsize;
            children(i).ZLabel.FontSize = fontsize;
            
            if numchild ==1 && tight
%                 fig.Resize = 'on';
                if keepAscpect
                            ax = children(i);
                            ax.Units = 'centimeter';
                            pos = ax.Position;
                            axratio = pos(4)/pos(3);

                            ti = ax.TightInset;

                            left = ti(1);
                            bottom = ti(2);
                            figureWidth = textwidth*figwidth; % in cm
                            ax_width = figureWidth - ti(1) - ti(3); % in cm
                            figureHeight = ax_width*axratio + ti(2) + ti(4); % in cm
                            ax_height = ax_width*axratio; % in cm

                            ax.Position = [left bottom ax_width ax_height];

                            figdim = [figureWidth figureHeight];
                end
                ti = ax.TightInset;
                ax.LooseInset= ti;
            end
        end
    end
    
    
    
    fig.PaperSize =  figdim;
    fig.PaperPosition= [0, 0, figdim];
    
    if numchild == 1 && tight
        fig.InnerPosition= [0, 0, figdim];
    end
    

    % save the file
    
    filenamepath = fullfile(pathstr, [name '.' format]);
    print(fig, ['-d' format], '-r600','-painters', filenamepath)
    
    if remClipping
        scriptfile = fullfile(fileparts(mfilename('fullpath')), 'remClipping.vbs');
        commandstring = sprintf('cscript //NoLogo %s "%s"', scriptfile,filenamepath);
        [clipRemove_status,message] = dos(commandstring)
    end
    
    % clean up
%     fig.delete();
	
	% turn on warnings:
	warning('on', 'MATLAB:handle_graphics:exceptions:SceneNode')
	warning('on', 'MATLAB:copyobj:ObjectNotCopied')
end
