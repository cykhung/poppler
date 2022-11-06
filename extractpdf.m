function extractpdf(srcfilename, pagenums, dstfilename)

%%
%       SYNTAX: extractpdf(srcfilename, pagenums, dstfilename);
%
%  DESCRIPTION: Extract pages from a PDF file.
%
%        INPUT: - srcfilename (char or N-D cell array of char or 
%                                      N-D array of categorical)
%                   Input PDF filename. Scalar.
%
%               - pagenums (N-D array of real double)
%                   Page numbers to extract, e.g. if you want to extract page 1,
%                   3, 5 and 6, then set this input argument to [1 3 5 6].
%
%               - dstfilename (char or N-D cell array of char or 
%                                      N-D array of categorical)
%                   Output PDF filename. Scalar.
%
%       OUTPUT: none.


%% Force filename into cell array.
srcfilename = char(convert_filenames(srcfilename));
dstfilename = char(convert_filenames(dstfilename));


%% Define poppler pdfseparate.exe and pdfunite.exe.
poppler_pdfseparate = fullfile(fileparts(mfilename('fullpath')), 'private', ...
    'poppler-0.51.0', 'bin', 'pdfseparate.exe');
poppler_pdfunite = fullfile(fileparts(mfilename('fullpath')), 'private', ...
    'poppler-0.51.0', 'bin', 'pdfunite.exe');


%% Separate src PDF file into multiple temporary PDF files (one PDF per page
%% number)
tmpfilenames      = cell(size(pagenums));
tmpfilenameprefix = [tempname, '-', mfilename, '-'];
pagenums          = pagenums(:);
for n = 1:numel(pagenums)
    
    % Get temporary filename.
    tmpfilenames{n} = [tmpfilenameprefix, num2str(n, '%06d'), '.pdf'];

    % Call poppler pdfseparate.exe.
    cmd = sprintf('"%s" -f %d -l %d "%s" "%s"',                     ...
                  poppler_pdfseparate,                              ...
                  pagenums(n),                                      ...
                  pagenums(n),                                      ...
                  srcfilename,                                      ...
                  tmpfilenames{n});
    dos(cmd);

end


%% Unite
cmd = sprintf('"%s" ', poppler_pdfunite);
for n = 1:numel(tmpfilenames)
   cmd = [cmd, sprintf('"%s" ', tmpfilenames{n})];      %#ok<AGROW>
end
cmd = [cmd, sprintf('"%s"', dstfilename)];
dos(cmd);


%% Delete all temporary PDF files.
rm(tmpfilenames, 0);


end