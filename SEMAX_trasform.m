%% conteo version 4.0 december 4 2018
tic
%% sumation of hmax
Hmax = max(max(tmp)-min(tmp(tmp>0)));
H = R.CellExtentInWorldX:R.CellExtentInWorldX*10:Hmax;
% % tic
% % hmax=zeros([size(dsm2) numel(H)],'uint8');
% % Iact = dsm2;
% % for j=1:numel(H)
% %     hmax(:,:,j) = imextendedmax(Iact,H(j)).*poly;
% %     if j>2
% %         hmax(:,:,j) = hmax(:,:,j) | hmax(:,:,j-1);
% %         hmax(:,:,j) = imfill(hmax(:,:,j),'holes');
% %     end
% % %     cdsm = Hmax-dsm2;
% % %     Iact = Hmax-imimposemin(cdsm,img(:,:,j));
% %     %subplot(121)
% %     %imagesc(Iact)
% %     %drawnow
% %     %subplot(122)
% %     %imagesc(sum(img(:,:,1:j),3))
% %     %drawnow
% % end
% % Shmax=sum(hmax,3);
% % toc
%tic
% Shmax = zeros(size(dsm2));
% Iact = dsm2;
% 
% %plot(line,'r')
% for j=1:numel(H)
%     hnew = imregionalmax((imreconstruct((Iact-H(j)), Iact)));
%     %   figure(1)
%     %  hold on
%     % plot(hnew.*line)
%     %pause()
%     if j>2
%         hnew = hnew | hant;
%         hnew = imfill(hnew,'holes');
%     end
%     Shmax = Shmax+hnew;
%     hant=hnew;
% end
%toc
% figure(10)
% imagesc(Shmax)
%% morphologic gradient of Shmax
se=strel('disk',1);
GShmax = imdilate(Shmax,se)-imerode(Shmax,se);
% figure(2)
% imagesc(GShmax)
%% Local Maxima of Shmax
h=hh;
Lhmax = imextendedmax(Shmax,h);
%lma = imhmax(Shmax,h);
% figure(3);imagesc(Lhmax)
%%
Sp1 = watershed(imimposemin(max(Shmax(:))-Shmax,Lhmax));
%Sp = watershed(imimposemin(GShmax,Lhmax));
Sp1(not(poly)) = 0;
% figure(4)
% imagesc(imgt(:,:,1:3))
% hold on
% visboundaries(Sp2)
%% skelet and watershed

Sp2 = watershed(imimposemin(GShmax,Lhmax|(Sp1==0).*poly));
%Sp2 = watershed(imimposemin(GShmax,Lhmax|(Sp1==0)));
%Sp2 = watershed(imimposemin(max(Shmax(:))-Shmax,Lhmax|(Sp1==0).*poly));
Sp2(not(poly)) = 0;
% figure(8)
% imagesc(Shmax(1986:3020,1960:3083))
% hold on
% visboundaries(Sp2(1986:3020,1960:3083))

Sp=Sp2;


Xmedgrad = arrayfun(@(x) Shmax((Sp(:)==x)),unique(Sp),'UniformOutput',0);

Xmedgrad2 = cellfun(@(x) numel(unique(x(x>0))),Xmedgrad);

%% Hmax/2 mayor ruido
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
    %labels = zeros(size(Sp));
    %for i=3:numel(Sps)
        %labels(Sp(:)==Sps(i)) = ind(i);
    %end
    % figure(5)
    % imagesc(labels)
    rst{lj} = bwlabel(labels);
end
%aa = rst{1};
%figure(1);imagesc(aa)
%toc
%%
%imagesc(imgt2(1986:3020,1960:3083,:))
%hold on
%visboundaries(rst(1986:3020,1960:3083))
