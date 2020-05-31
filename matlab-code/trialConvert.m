input_folder = '/Users/manishm/Work/vanDerMeerLab/NWB/data/MotivationalT-v2/R050/R050-2014-03-31_raw/';
ncs_in = '/Users/manishm/Work/vanDerMeerLab/NWB/data/MotivationalT-v2/R050/R050-2014-03-31_raw/R050-2014-03-31-CSC01a.ncs';
output_folder = '/Users/manishm/Work/vanDerMeerLab/NWB/data/R50_converted/';

%Get the list of ntt files in the input directory
searchString = strcat(2,input_folder,'*.ntt');
if searchString(1) ~= '/'
    searchString = searchString(2:end);
end
ntt_list = dir(searchString);


%% ConvertNtttoNcs: convert a .ntt discontinuous file into multiple .ncs continously sampled files 
for idx = 1:length(ntt_list)
    ntt_in = [ntt_list(idx).folder,'/',ntt_list(idx).name];
    [Timestamps, ScNumbers, CellNumbers, Features, Samples, Header] =  Nlx2MatSpike(ntt_in, [1 1 1 1 1], 1, 1, [] );
    % Get Common timebase from the .ncs file
    %TODO: find a better way to find the common timebase
    Fs = regexp([Header{:}],'(?<=SamplingFrequency[^0-9]*)[0-9]*','match'); 
    Fs  = str2double(Fs{1});
    [csc_Timestamps, ~, ~, csc_NumberOfValidSamples, csc_Samples, csc_Header] = Nlx2MatCSC(ncs_in, [1 1 1 1 1], 1, 1, []);
    step = 1e6/Fs;
    tvec = csc_Timestamps(1):step:csc_Timestamps(end)+1000000;
    raw_form = zeros(4,length(tvec));
    
    rid1 = zeros(1,length(Timestamps));
    rval1 = zeros(1, length(rid1));
    % rid2 = rid1;
    % rval2 = rval1;
    % nanlist = isnan(tvec);
    for i = 1:length(rid1)
        lo = 1;
        hi = length(tvec);
        %TODO: Fix edge cases for the binary search
        %tic;
        while(lo <= hi)
            mid = floor((lo+hi)/2);
            if Timestamps(i) < tvec(mid)
                if abs(Timestamps(i)-tvec(mid)) <= abs(Timestamps(i)-tvec(mid-1))
                    rval1(i) = abs(Timestamps(i)-tvec(mid));
                    rid1(i) = mid;
                    break;
                else
                    hi = mid-1;
                    continue
                end
            end
            if Timestamps(i) > tvec(mid)
                if abs(Timestamps(i)-tvec(mid)) <= abs(Timestamps(i)-tvec(mid+1))
                    rval1(i) = abs(Timestamps(i)-tvec(mid));
                    rid1(i) = mid;
                    break;
                else
                   lo = mid+1;
                    continue
                end
            end
            % if Timestamps(i) == tvec(mid)
            rval1(i) = abs(Timestamps(i)-tvec(mid));
            rid1(i) = mid;
            break;
        end
        cur_sample = Samples(:,:,i);
        cur_sample = permute(cur_sample,[2,1]);
        if (i == 1)
            raw_form(:,rid1(i)-7:rid1(i)+24) = cur_sample;
        else
            if rid1(i) - rid1(i-1) >= 32
                raw_form(:,rid1(i)-7:rid1(i)+24) = cur_sample;
            else
                prev_sample = Samples(:,:,i-1);
                prev_sample = permute(prev_sample,[2,1]);
                % This should ideally be unncessary, but just to be sure and
                % avoid discrepancies due to rounding errors in timebin
                % assignment
                odx = findOverlap(prev_sample, cur_sample);
                if odx == 0
                    disp('Overlap failed')
                else
    %                 disp(strcat(2, 'Overlap:',num2str(rid1(i) - rid1(i-1)),', ',num2str(odx)));
                    raw_form(:,rid1(i)-7:rid1(i)+24) = cur_sample;
                end
            end

        end
    end

    %     toc;
        % Naive way to find the c
    %     tic;
    %     [rval2(i), rid2(i)] = nanmin(abs(tvec-Timestamps(i)));
    %     toc;
    %     disp(strcat(2,'Method1: ',num2str(rid1(i))));
    %     disp(strcat(2,'Method2: ',num2str(rid2(i))));
    %Get the list of ntt files in the input directory
    output_suffix = ntt_list(idx).name(strfind(ntt_list(idx).name,'TT'): strfind(ntt_list(idx).name,'.')-1);
    output_file = strcat(2,output_folder,'/temp_',output_suffix,'.dat');
    if output_file(1) ~= '/'
        output_file = output_file(2:end);
    end
    output_ts_file = strcat(2,output_folder,'/Timestamps_',output_suffix,'.mat');
    if output_ts_file(1) ~= '/'
        output_ts_file = output_ts_file(2:end);
    end
    fidOut = fopen(output_file, 'w');
    fwrite(fidOut, raw_form, 'int16');
    fclose(fidOut);
    save(output_ts_file,'rid1');

    % TODO: Version 2: Replace long segments of zero with  with staight lines
end

% Finds the overlapping bins between two close occuring spike waves
% S1 is the prev sample, S2 is the current sample
function iD  = findOverlap(S1,S2)
    iD = 0;
    % TODO: Find a more robust way of doing this
    l1 = find(S2(1,:) == S1(1,end));
    l2 = find(S2(2,:) == S1(2,end));
    l3 = find(S2(3,:) == S1(3,end));
    l4 = find(S2(4,:) == S1(4,end));
    id1 = intersect(intersect(l1,l2),intersect(l3,l4));
    r1 = find(S1(1,:) == S2(1,1));
    r2 = find(S1(2,:) == S2(2,1));
    r3 = find(S1(3,:) == S2(3,1));
    r4 = find(S1(4,:) == S2(4,1));
    id2 = intersect(intersect(r1,r2),intersect(r3,r4));
    seg1 = S1(:,id2:end);
    seg2 = S2(:,1:id1);
    if numel(seg1) ~= numel(seg2)
        disp('Erroneous overlap')
    end
    if numel(find(seg1==seg2)) == numel(seg1)
        iD = id1;
    end
end
