input_folder = '/Users/manishm/Work/vanDerMeerLab/NWB/data/R50_converted/';
output_file = '/Users/manishm/Work/vanDerMeerLab/NWB/data/R50_converted/all_channels.dat';
%Get the list of binary files in the input directory
searchString = strcat(input_folder,'temp*dat');
flist = dir(searchString);
fid_write = fopen(output_file, 'w');
for j = 1:length(flist)
    fid_read = fopen(strcat(input_folder,flist(j).name));
    A = fread(fid_read, '*int16');
    fwrite(fid_write, A, 'int16')
    fclose(fid_read);
end
fclose(fid_write);