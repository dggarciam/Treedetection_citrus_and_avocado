
% treedetection 5.0 January 2020
%  * Author:    Daniel G. García Murillo
%  * Version    5.0
%  * Created:   January 2020

%% sumation of hmax
Hmax = max(max(dsm2)-min(dsm2(dsm2>0))); 
H = R.CellExtentInWorldX:R.CellExtentInWorldX:Hmax;
tic
hmax=zeros([size(dsm2) numel(H)],'uint8');
Iact = dsm2;
for j=1:numel(H)
    hmax(:,:,j) = imextendedmax(Iact,H(j)).*poly;
    if j>2
        hmax(:,:,j) = hmax(:,:,j) | hmax(:,:,j-1);
        hmax(:,:,j) = imfill(hmax(:,:,j),'holes');
    end
end
Shmax=sum(hmax,3);
toc
%% morphologic gradient of Shmax
se=strel('disk',1);
GShmax = imdilate(Shmax,se)-imerode(Shmax,se);
%% Local Maxima of Shmax
Lhmax = imextendedmax(Shmax,hh);
%%
Sp1 = watershed(imimposemin(max(Shmax(:))-Shmax,Lhmax));
Sp1(not(poly)) = 0;
%% skelet and watershed
Sp = watershed(imimposemin(GShmax,Lhmax|(Sp1==0).*poly));
Sp(not(poly)) = 0;
%% evenness measure
Xmedgrad = arrayfun(@(x) Shmax((Sp(:)==x)),unique(Sp),'UniformOutput',0);
Xmedgrad2 = cellfun(@(x) numel(unique(x(x>0))),Xmedgrad);
%% Classification stage
Th=0:20;
rst=cell(numel(Th),1);
for lj = 1:numel(Th)
    ind = Xmedgrad2>Th(lj);
    ind(1)=0;
    ind(2)=0;
    Sps = unique(Sp(:));
    del = Sps(not(ind));
    labels=Sp;
    for i=1:numel(del)
        labels(Sp(:)==del(i))=0;
    end
    rst{lj} = bwlabel(labels);
end
