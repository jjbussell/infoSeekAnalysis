pathname=uigetdir;
files=dir([pathname,'/*.csv']);
mkdir(pathname,'/Fixed');
numFiles = size(files,1);

f = 1;

for f = 1:numFiles
    filename = files(f).name;
    fname = fullfile(pathname,filename);
    clearvars -except filename fname files pathname numFiles f
    

    fileID=fopen(fname);
    C = textscan(fileID,'%s', 'Delimiter', ',','MultipleDelimsAsOne',1);
    fclose(fileID);
    
    allData = C{1,1};
    firstZeros = find(strcmp(allData,'0'),20);
    firstZerosDiff = find(diff(firstZeros)==1,1);
    firstData = firstZeros(find(diff(firstZeros)==1,1));
    paramsStop = floor((find(strcmp('Touch_Left',allData))+1)/2)-1;
    paramRead = find(strcmp('Touch_Left',allData))+1;

    dataStart = floor((firstData-paramRead)/5) + paramsStop + 1;

%     dataStart = (firstData-1)/2;
    data = csvread(fname,dataStart,0);
  
    if size(data,2)>5
        badRows = unique([find(data(:,6));find(data(:,7));find(data(:,8));find(data(:,9))]);

        if ~isempty(badRows)
            if numel(find(data(:,6)))>numel(badRows)
                display('Error');
                break
            end

            for n = 1:numel(badRows)
                if n<numel(badRows)
                if badRows(n+1)==badRows(n)+2
                    n = n+1;
                    row = badRows(n);
                end
                end
               trial = data(row+1,2);


               replaceStart = find(data(row,:)==trial);
               replace = data(row,replaceStart:replaceStart+3);
               data(row,2:5)=replace;
               data(row-1:row,1) = data(row+1,1);

               if find(data(row-2,6))
                  replace2Start = find(data(row-2,:)==trial);  
                  data(row-2,2:5) = data(row-2,replace2Start:replace2Start+3);
                  data(row-2,1) = data(row-3,1);          
               end       
            end

            data2 = data(:,1:5);
        end
    else
        data2 = data;
    end
    
    paramThings = C{1,1};
    params(:,1) = paramThings(1:2:paramRead);
    params(:,2) = paramThings(2:2:paramRead);
    params(:,3:5) = {[]};
    cellData = num2cell(data2);
    all = [params; cellData];
    
    
    writetable(cell2table(all),[pathname '\Fixed\' filename(1:end-4) '_mod.csv'],'WriteVariableNames',0);


end