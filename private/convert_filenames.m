function filenames = convert_filenames(filenames)

%%
%       SYNTAX: filenames = convert_filenames(filenames);
%
%  DESCRIPTION: Convert filenames to cell array.
%
%        INPUT: - filenames (char or N-D cell array of char or 
%                                    N-D array of categorical)
%                   Filename(s).
%
%       OUTPUT: - filenames (N-D cell array of char)
%                   Filename(s).

%% Convert filenames to cell array of char. 
if ischar(filenames)
    filenames = {filenames};
elseif iscategorical(filenames)
    filenames = cellstr(filenames);
end

%% Make filename separator to be Linux and Windows friendly.
filenames = strrep(filenames, '\', filesep);
filenames = strrep(filenames, '/', filesep);

end
