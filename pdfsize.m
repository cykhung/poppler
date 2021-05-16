function T = pdfsize(filenames)

%%
%       SYNTAX: T = pdfsize(filenames);
%
%  DESCRIPTION: Get page size of each page in each PDF file.
%
%               File Exchange: Extract text from a PDF document
%                              https://goo.gl/qD0OpL
%
%               Cannot handle "sldf\print\sldf_A_Exercises_note.pdf".
%
%        INPUT: - filenames (char or N-D cell array of char or 
%                                    N-D array of categorical)
%                   Filename(s).
%
%       OUTPUT: - T (table)
%                   Table.


%% Force filenames into cell array.
filenames = convert_filenames(filenames);


%% Process one PDF at a time.
popplerexe = fullfile(fileparts(mfilename('fullpath')), 'bin', 'pdfinfo.exe');
T          = table;
for n = 1:numel(filenames)
    
    % Get number of pages in the PDF file.
    [~, docinfo] = dos(sprintf('%s "%s"', popplerexe, filenames{n}));
    infostr      = strsplit(docinfo, '\n');
    pageidx      = ~cellfun(@isempty,regexp(infostr, '^Pages:'));
    tmp          = strsplit(infostr{pageidx});
    if (length(tmp) ~= 2) || ~strcmp({'Pages:'}, 'Pages:')
        error('Invalid format.');
    end
    numpages = str2double(tmp{2});
    if isnan(numpages)
        error('Invalid numpages.');
    end
    
    % Get the page size of each page.
    cmd           = sprintf('%s -f 1 -l %d "%s"',   ...
                            popplerexe,             ...
                            numpages,               ...
                            filenames{n});
    [~, pageinfo] = dos(cmd);
    pagestr       = strsplit(pageinfo, '\n');
    sizeidx       = ~cellfun(@isempty, regexp(pagestr, '^Page.*size:'));
    pages         = pagestr(sizeidx);
    if length(pages) ~= numpages
        error('Invalid length(tmp).');
    end
    widthInch  = NaN(numpages, 1);
    heightInch = NaN(numpages, 1);
    for m = 1:length(pages)
        tmp           = strsplit(pages{m});
        widthInch(m)  = round(str2double(tmp{4}) / 72, 2); % 72 points per inch.
        heightInch(m) = round(str2double(tmp{6}) / 72, 2); % 72 points per inch.
    end    
    
    % Put page size into table T.
    T1            = table;
    T1.filename   = repmat(categorical(filenames(n)), numpages, 1);
    T1.page       = (1:numpages)';
    T1.widthInch  = widthInch;
    T1.heightInch = heightInch;
    T             = [T; T1];                %#ok<AGROW>
    
end


end






