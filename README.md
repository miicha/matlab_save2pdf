## textools

Sammlung von Tools, die das Arbeiten mit LaTeX einfacher machen sollen.

### save2pdf.m
Matlab-Skript, mit dem sich `figure`s mit getexten `label`s, `legend`s und `tick`s
einfach in der richtigen Größe zum Einbinden in TeX-Dokumente erstellen lassen.

#### API:
- `save2pdf( filename, options )`

    Saves a figure to a pdf in a nice size and with texed text.
    
    `filename`      - Path (absolute or relative to the current working dir).
    
    `varargin`:
     - `width`       - Adjusts font sizes so that they are readable with
                    different figure widths for a4paper. Default: `0.8*\textwidth`.
     - `aspectratio` - Aspect ratio. Defaults to `height/width = 3/5`.
     - `figure`      - Figure to save. Default: `gcf`.
     - `texify`      - Texify the labels and legends. Default: `true`.
     - `escape`      - escapes ` ` and `~`, which cannot be parsed by LaTeX.
                    Default: `true`.
     - `fontsize`    - Font size in pt. Defaults to `11`.
     - `textwidth`   - Textwidth of your LaTeX page in cm. Default: `17`.
    
    Example:   
    ```
    plot(1:10);
    xlabel('bla');
    legend({'curve 1'});
    save2pdf('plot', 'width', 0.8)
    ```