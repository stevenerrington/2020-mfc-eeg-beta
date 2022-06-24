function data = SEF_LFP_Filter( input, samplingFreq, bandFreq, bandName, filt_order, varargin )

band_name_time = [bandName '_time'];
band_name_fs = [bandName '_fs'];

data.(bandName).hpc = bandFreq(2);
data.(bandName).lpc1 = bandFreq(1);
data.(bandName).lpc2 = bandFreq(1)/2;

data.(bandName).filt_order = filt_order;

do_power = false;
do_oscil = true;

varStrInd = find(cellfun(@ischar,varargin));
for iv = 1:length(varStrInd)
    switch varargin{varStrInd(iv)}
        case {'-p','power'}
            do_power = varargin{varStrInd(iv)+1};
        case {'-o','oscil'}
            do_oscil = varargin{varStrInd(iv)+1};
    end
end

if strcmp(bandName, 'mua')
    do_oscil = false;
end

hWn = data.(bandName).hpc / (samplingFreq/2);
[ bwb, bwa ] = butter( filt_order, hWn, 'high' );

hphga = filtfilt( bwb, bwa, input' );

lWn = data.(bandName).lpc1 / (samplingFreq/2);
[ bwb, bwa ] = butter( filt_order, lWn, 'low' );
hphga = filtfilt( bwb, bwa, hphga );

if do_oscil
    
    hphga_d = [];
    if samplingFreq > G_FS('slow')*1.5
        for i = 1 : size(hphga, 2)
            hphga_d = cat(2,hphga_d, decimate2( hphga(:,i), single(floor(samplingFreq / G_FS('slow'))) ));
        end
        new_fs = samplingFreq / (single(floor(samplingFreq / G_FS('slow'))));
    else
        hphga_d = hphga;
        new_fs = samplingFreq;
    end
    

    data.data = single(hphga_d');
    data.(band_name_fs) = new_fs;
    data.(band_name_time) = 0:(size(hphga_d, 1) - 1);
    data.(band_name_time) = data.(band_name_time) .* (1000 / data.(band_name_fs));
end

if do_power
    
    if strcmp(bandName, 'mua')
        band_name_power_time = [bandName '_time'];
        band_name_power_fs = [bandName '_fs'];
        band_name_power = bandName;
    else
        band_name_power_time = [bandName '_pwr_time'];
        band_name_power_fs = [bandName '_pwr_fs'];
        band_name_power = [bandName '_pwr'];
    end
    
    hphga = abs( hphga );
    
    lWn = data.(bandName).lpc2 / (samplingFreq/2);
    [ bwb, bwa ] = butter( filt_order, lWn, 'low' );
    hphga = filtfilt( bwb, bwa, hphga );
    
    hphga_p = [];
    if samplingFreq > G_FS('slow')*1.5
        for i = 1 : size(hphga, 2)
            hphga_p = cat(2,hphga_p, decimate2( hphga(:,i), single(floor(samplingFreq / G_FS('slow'))) ));
        end
        new_fs = samplingFreq / (single(floor(samplingFreq / G_FS('slow'))));
    else
        hphga_p = hphga;
        new_fs = samplingFreq;
    end
    
    data.(band_name_power) = single(hphga_p');
    data.(band_name_power_fs) = new_fs;
    data.(band_name_power_time) = 0:(size(hphga_p, 1) - 1);
    data.(band_name_power_time) = data.(band_name_power_time) .* (1000 / data.(band_name_power_fs));
end

end