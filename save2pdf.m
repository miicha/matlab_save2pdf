function [fig_dim_out] = save2pdf( filename, varargin )
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
    %   markersize  - to resize the markers input the desired size
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
    
    if isstring(filename)
        filename = cellstr(filename);
        filename = filename{1};
    end
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
    legend_fontsize = tick_fontsize;
    textwidth = 17; % cm
    format = 'pdf';
    keepAscpect = false;
    remClipping = false;
    figdim =[];
    tight = false;
    resizemarkers = false;
    markerPos = [];
    tokenSize = [30,18];
    legend_fontsize_set = false;
    tick_fontsize_set = false;
    
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
                if ~tick_fontsize_set 
                    tick_fontsize = fontsize-2;
                end
                if ~legend_fontsize_set             
                    legend_fontsize = fontsize-2;
                end
            case 'text'
                textwidth = varargin{i+1};
            case 'form'
                format = varargin{i+1};
            case 'tick'
                tick_fontsize = varargin{i+1};
                tick_fontsize_set = true;
            case 'keep'
                keepAscpect = varargin{i+1};
            case 'remo'
                remClipping = varargin{i+1};
            case 'fixs'
                figdim = varargin{i+1};
            case 'mark'
                resizemarkers = true;
                markersize = varargin{i+1};
            case 'tigh'
                tight = varargin{i+1};
            case 'toke'
                tokenSize = varargin{i+1};
            case 'mpos'
                markerPos = varargin{i+1};
            case 'lege'
                legend_fontsize = varargin{i+1};
                legend_fontsize_set = true;
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
        legendo = {'interpreter', 'latex', 'FontSize', legend_fontsize};
    else
        legendo = {'FontSize', legend_fontsize};
    end
    
    fig.PaperSize =  figdim;
    fig.PaperPosition= [0, 0, figdim];

    children = fig.Children;
    numchild = 0;
    for i = 1:length(children)
        if isa(children(i), 'matlab.graphics.axis.Axes')
            if resizemarkers
                axeschildren = children(i).Children;
                for j = 1:length(axeschildren)
                    switch class(axeschildren(j))
                        case 'matlab.graphics.chart.primitive.Scatter'
                            axeschildren(j).SizeData = markersize;
                    end
                end
            end
            numchild = numchild+1;
            if texify
                children(i).TickLabelInterpreter = 'latex';
            end
            
            for j = 1:length(children(i).XAxis)
                children(i).XAxis(j).Label.FontSize = fontsize;
                if texify
                    if ~strcmp(children(i).XAxis(j).Label.Interpreter,'latex')
                        
                        children(i).XAxis(j).Label.String = regexprep(children(i).XAxis(j).Label.String, '(\\\w+_?\\?\w*)','\$\$$1\$\$');
                        children(i).XAxis(j).Label.String = strrep(children(i).XAxis(j).Label.String, '\mus','\mu s');
                        children(i).XAxis(j).Label.Interpreter = 'latex';
                    end
                end
            end
            for j = 1:length(children(i).YAxis)
                children(i).YAxis(j).Label.FontSize = fontsize;
                if texify
                    if ~strcmp(children(i).YAxis(j).Label.Interpreter,'latex')
                        children(i).YAxis(j).Label.String = strrep(children(i).YAxis(j).Label.String, '#','$$\#$$');
                        children(i).YAxis(j).Label.String = regexprep(children(i).YAxis(j).Label.String, '(\\\w+\^?_?\\?\w*)','\$\$$1\$\$');
                        children(i).YAxis(j).Label.String = strrep(children(i).YAxis(j).Label.String, '\mus','\mu s');
                        children(i).YAxis(j).Label.Interpreter = 'latex';
                    end
                end
            end
            for j = 1:length(children(i).ZAxis)
                children(i).ZAxis(j).Label.FontSize = fontsize;
                if texify
                    if ~strcmp(children(i).ZAxis(j).Label.Interpreter,'latex')
                        
                        children(i).ZAxis(j).Label.String = regexprep(children(i).ZAxis(j).Label.String, '(\\\w+_?\\?\w*)','\$\$$1\$\$');
                        children(i).ZAxis(j).Label.String = strrep(children(i).ZAxis(j).Label.String, '\mus','\mu s');
                        children(i).ZAxis(j).Label.Interpreter = 'latex';
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
            if texify
                if ~strcmp(children(i).Interpreter,'latex')
                    for j = 1:length(children(i).String)
                        children(i).String{j} = regexprep(children(i).String{j}, '(\\\w+_?\\?\w*)','\$\$$1\$\$');
                        children(i).String{j} = strrep(children(i).String{j}, '\mus','\mu s');
                    end
                end
            end
            set(children(i), legendo{:})
            hLeg = children(i);
        end
        if isa(children(i), 'matlab.graphics.illustration.ColorBar')
            if texify
                set(children(i), 'TickLabelInterpreter', 'latex')
            end
            set(children(i), 'FontSize', tick_fontsize)
        end
    end
    drawnow
    for i = 1:length(children)
        if isa(children(i), 'matlab.graphics.axis.Axes')
            ax = children(i);
            children(i).FontSize = tick_fontsize;
            if length(ax.Tag)<10 || ~strcmpi(ax.Tag(1:10),'PlotMatrix')
                children(i).ActivePositionProperty = 'OuterPosition'; % Beschriftung nicht abschneiden
            end
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
    
    % change text in TextBoxes
    h = findobj(fig, 'Type', 'TextBox');
    for i = 1:length(h)
        h(i).FontSize = tick_fontsize;
        if texify
           h(i).Interpreter = 'latex';
        end
    end
    
    % set paper size and position
    fig.PaperSize =  figdim;
    fig.PaperPosition= [0, 0, figdim];
    
    if numchild == 1 && tight
        fig.InnerPosition= [0, 0, figdim];
    end
    

    % save the file
    if exist('hLeg','var')
        squeeze_legend(hLeg,tokenSize,markerPos);
    end
    
    filenamepath = fullfile(pathstr, [name '.' format]);
    print(fig, ['-d' format], '-r600','-painters', filenamepath)
    
    if remClipping && verLessThan('matlab', '9.5')
        scriptfile = fullfile(fileparts(mfilename('fullpath')), 'remClipping.vbs');
        commandstring = sprintf('cscript //NoLogo %s "%s"', scriptfile,filenamepath);
        [clipRemove_status,message] = dos(commandstring)
    end
    if nargout == 1
        fig_dim_out = figdim;
    end
    % clean up
%     fig.delete();
	
	% turn on warnings:
	warning('on', 'MATLAB:handle_graphics:exceptions:SceneNode')
	warning('on', 'MATLAB:copyobj:ObjectNotCopied')
end

function squeeze_legend(hLeg,tokenSize,markerPos)

if ~isempty(markerPos)
    for i = 1:length(hLeg.EntryContainer.Children)
        drawnow
        hLegendEntry = hLeg.EntryContainer.Children(i);
        hLegendIconLine = hLegendEntry.Icon.Transform.Children.Children;
        hLegendIconLine.VertexData(1) = markerPos;
    end
end
hLeg.ItemTokenSize = tokenSize;
end
