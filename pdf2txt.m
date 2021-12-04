function pdf2txt(varargin)

%%
%       SYNTAX: pdf2txt(pdffilenames, txtfilenames);
%               pdf2txt(topdir);
%
%  DESCRIPTION: Convert PDF files to plain text files.
%
%        INPUT: - pdffilenames (char or N-D cell array of char or 
%                                       N-D array of categorical)
%                   PDF filename(s).
%
%               - txtfilenames (char or N-D cell array of char or 
%                                       N-D array of categorical)
%                   Plain text filename(s).
%
%               - topdir (char or N-D cell array of char)
%                   Top-level directories.
%
%       OUTPUT: none.


%% Assign input arguments.
switch nargin
case 1
    topdir = varargin{1};
case 2
    pdffilenames = varargin{1};
    txtfilenames = varargin{2};
otherwise
    error('Invalid number of input arguments.');
end


%% Convert files.
switch nargin
case 1
    
    % Recursively find all PDF files under top-level directory.
    if ~iscell(topdir)
        topdir = {topdir};
    end
    s = [];
    for n = 1:numel(topdir)
        x = fullfile(topdir{n}, '**', '*.pdf');
        s = [s; dir(x)];
    end
    s1          = struct;
    s1.name     = {s.name}';
    s1.folder   = {s.folder}';
    s1.filename = fullfile(s1.folder, s1.name);

    % Generate filenames for all TXT files.
    T     = table;
    T.src = s1.filename;
    x     = strrep(s1.name, '.pdf', '_ckhpdf2txt.txt');
    T.dst = fullfile(s1.folder, x);
    
    % % Make sure that all TXT filenames do not exist yet.
    % for n = 1:numel(T.dst)
    %     if exist(char(T.dst(n)), 'file') ~= 0
    %         error('File "%s" exists.', char(T.dst(n)));
    %     end
    % end
    
    % Add T.srclen and T.dstlen.
    T.srclen = NaN(size(T.src));
    T.dstlen = T.srclen;
    for n = 1:length(T.src)
        T.srclen(n) = length(char(T.src(n)));
        T.dstlen(n) = length(char(T.dst(n)));
    end
    
    % Do conversion.
    N1 = max(T.srclen);
    N2 = max(T.dstlen);
    for n = 1:numel(T.dst)
        b1 = repmat(' ', 1, N1 - T.srclen(n));
        b2 = repmat(' ', 1, N2 - T.dstlen(n));
        fprintf('Convert "%s" %sto "%s". %s',   ...
                char(T.src(n)),                 ...
                b1,                             ...
                char(T.dst(n)),                 ...
                b2);
        if exist(char(T.dst(n)), 'file') ~= 0
            s1 = dir(char(T.src(n)));
            s2 = dir(char(T.dst(n)));
            if s2.datenum > s1.datenum
                fprintf('Skip.\n');
            else
                pdf2txt(T.src(n), T.dst(n));
                % fprintf('Done.\n');
                cprintf('red', 'Done.\n');
            end
        else
            pdf2txt(T.src(n), T.dst(n));
            % fprintf('Done.\n');
            cprintf('red', 'Done.\n')
        end
    end    
    
case 2

    % Convert filenames to cell array of char.
    pdffilenames = convert_filenames(pdffilenames);
    txtfilenames = convert_filenames(txtfilenames);
    
    % Check pdffilenames and txtfilenames.
    if any(size(pdffilenames) ~= size(txtfilenames))
        error('Mismatch in sizes of pdffilenames and txtfilenames');
    end
    
    % Convert PDF files to TXT files.
    for n = 1:numel(pdffilenames)
        convertfile(pdffilenames{n}, txtfilenames{n});
    end

otherwise
    error('Invalid number of input arguments.');
end
    

end



function convertfile(pdffilename, txtfilename)


%% Call pdftotext.exe.
exe = fullfile(fileparts(mfilename('fullpath')), 'private', ...
    'poppler-0.51.0', 'bin', 'pdftotext.exe');
cmd = sprintf('"%s" -layout "%s" "%s"', exe, pdffilename, txtfilename);
dos(cmd);


end


        