clc

count=0;

name=zeros(2,7);

off_sem=readtable('Offre_Semaine_Etudecas2.csv'); %Lecture de la Table CSV demandée

%Il faut choisir la plage horaire souhaitée en format décimal 
%(00:00=0, 06:00=0.25, 09:00=0.375,12:00=0.5, 18:00=0.75, 21:00=0.875 )

off_sem=off_sem((off_sem{:,13})>=0 & (off_sem{:,13})<=1,:); 

e=1;
no_trajet=1
%Initialisations de la boucle 
for i=1:size(off_sem,1)-1
    if off_sem{i,6}==off_sem{i+1,6} && strcmp(off_sem{i,10},off_sem{i+1,10})==1
        off_sem{i,20}=no_trajet
    else
        no_trajet=no_trajet+1
        off_sem{i,20}=no_trajet
    end
end
        

for i=1:size(off_sem,1) 
    disp(i)
    if off_sem{i,13}==off_sem{i+1,13} && off_sem{i,6}==off_sem{i+1,6} && strcmp(off_sem{i,10},off_sem{i+1,10})==1  %Voir si heure départ similaire 
            count=count+1; % count le nombre de segment direct (AB, BC,...) dans le trajet. 
            disp(off_sem{i,6})
    else
        for j=i-count:i+count-1
            if j==size(off_sem,1)-1
                break
            end
            if isnan(off_sem{j,17})
                break 
            end
            for k=j:j+count
                if isnan(off_sem{k,17})
                    break
                end
                %name (xorigine, yorigine, xdestination, y destination, id
                %arret origine, id arret destination. 
                name(e,1:4)=[off_sem{j,15},off_sem{j,16},off_sem{k,17},off_sem{k,18}];
                name(e,5:7)=[off_sem{j,12},off_sem{k+1,12},off_sem{j,20}];
                e=e+1;
            end
       
        end
        count=0;    
    end
    if i==size(off_sem,1)-1
        for j=i-count+1:i+count-1
            if j==size(off_sem,1)
                break
            end
            if isnan(off_sem{j,17})
                break 
            end
            for k=j:j+count
                
                if k==size(off_sem,1) 
                    break
                end
                
                if isnan(off_sem{k,17})
                    break
                end
                name(e,1:4)=[off_sem{j,15},off_sem{j,16},off_sem{k,17},off_sem{k,18}];
                name(e,5:7)=[off_sem{j,12},off_sem{k+1,12},off_sem{j,20}];
                e=e+1;
            end
        end
        break
    end
end
 

name=name(name(:,1)>=0.5,:);
header = {'Xorigine','Yorigine','Xdestination','Ydestination','ID arret origine','ID arret destination','NoTrajet'};
output=[header;num2cell(name)];
disp(output)

%% Calcul du nombre de repetion du linestring par trajet 

Col_Concat=zeros(length(name),1);

for l=1:length(name) %Creation d'un ID qui concatane le id de la station de depart et celle d'arrivée.
    disp(l)
    Col_Concat(l,1)= str2num(strcat(num2str(name(l,5)),num2str(name(l,6)),num2str(name(l,7))));
end 

name=[name Col_Concat];

%Calcul du nombre de répetition
Rep=unique(name(:,8));
Rep_Count=histc(name(:,8),Rep);

Rep=[Rep Rep_Count];
disp(Rep)
Tableau_Resume=zeros(length(Rep),7);

for m=1:length(Rep)
    index=find([name(:,8)]==Rep(m,1));%Recherche ou l'ID trajet se trouve dans la matrix name.
    Tableau_Resume(m,1)=Rep(m,1) ;
    Tableau_Resume(m,2)=Rep(m,2);
    Tableau_Resume(m,3)=name(index(1),1); 
    Tableau_Resume(m,4)=name(index(1),2); 
    Tableau_Resume(m,5)=name(index(1),3); 
    Tableau_Resume(m,6)=name(index(1),4);
    Tableau_Resume(m,7)=name(index(1),7);
end

header = {'ID_originedestination','Nombre_de_repetition','Xorigine','Yorigine','Xdestination','Ydestination','NoTrajet'};
output2=[header;num2cell(Tableau_Resume)];
disp(output2);

Tableau_Resume=sortrows(Tableau_Resume,[7],'ascend');

no_id=1
Tableau_Resume(1,1)=no_id;

for i=1:size(Tableau_Resume,1)-1
    if Tableau_Resume(i,7)==Tableau_Resume(i+1,7)
        Tableau_Resume(i+1,1)=Tableau_Resume(i,1)
    else
        Tableau_Resume(i+1,1)=no_id+1;
        no_id=no_id+1
    end  
end

%Transformation en fichier txt
%Table de niveau 2 sans l'application de l'angle de similarité limite
Fich_txt=array2table(Tableau_Resume,'VariableNames',header);
writetable(Fich_txt,'MatrixTC_NonNettoye.txt','Delimiter','\t')

%% Nettoyage pour la dimension de niveau 2 

Fich_txt=sortrows(Fich_txt,{'Xorigine','Yorigine'},'ascend');
count=0;

for i=1:size(Fich_txt,1)
    if i<size(Fich_txt,1) && Fich_txt{i,3}==Fich_txt{i+1,3} && Fich_txt{i,4}==Fich_txt{i+1,4} 
            count=count+1; % count le nombre de segments qui ont la même origine 
    else 
        for j=i-count:i  
            if j==1
                Fich_txt{j,7}=atan2(Fich_txt{j,4} - Fich_txt{j,6},Fich_txt{j,3} - Fich_txt{j,5})*360/pi;
                Fich_txt{j,8}=nan;
                Fich_txt{j,9}=nan; 
            elseif j>1 && j<size(Fich_txt,1)
                Fich_txt{j,7}=atan2(Fich_txt{j,4} - Fich_txt{j,6},Fich_txt{j,3} - Fich_txt{j,5})*360/pi;
                Fich_txt{j,8}=Fich_txt{i-count,7} - Fich_txt{j,7}; %Angle par rapport point initial
                if Fich_txt{j,3}==Fich_txt{j-1,3} && Fich_txt{j,4}==Fich_txt{j-1,4}
                    Fich_txt{j,9}=Fich_txt{j,7} - Fich_txt{j-1,7};
                else
                    Fich_txt{j,9}=nan;
                end
            else
                Fich_txt{j,7}=atan2(Fich_txt{j,4} - Fich_txt{j,6},Fich_txt{j,3}-Fich_txt{j,5})*360/pi;
                Fich_txt{j,8}=Fich_txt{i-count,7} - Fich_txt{j,7}; %Angle par rapport point initial
                Fich_txt{j,9}=Fich_txt{j,7} - Fich_txt{j-1,7};
            end
        end
        count=0;
    end
end

Fich_txt_niv2_nonNettoye=Fich_txt;

header={'ID_originedestination','Nombre_de_repetition','Xorigine','Yorigine','Xdestination','Ydestination','Angle_Ligne','Angle_par_rapport_au_point_initial','Angle_par_rapport_au_segment_precedent'};
Fich_txt.Properties.VariableNames = header;

toDelete = abs(Fich_txt.Angle_par_rapport_au_segment_precedent) <= 10 & abs(Fich_txt.Angle_par_rapport_au_segment_precedent) > 0;

Fich_txt(toDelete,:) = [];

toDelete2=abs(Fich_txt.Angle_par_rapport_au_point_initial) <= 10 & abs(Fich_txt.Angle_par_rapport_au_point_initial) > 0;

Fich_txt(toDelete2,:) = [];

%% Calcul du Taux de détour (s'assure de ne pas compter les segments similaires deux fois ou plus  


A = table2array(Fich_txt)
B = table2array(Fich_txt_niv2_nonNettoye)

A = sortrows(A,[3 4 5 6])
B = sortrows(B,[3 4 5 6])

Concat=zeros(length(A),1)
Concat_B= zeros(length(B),1)

ID_similaire=1
A(1,10)=1
B(1,10)=1

for l=1:length(A)-1
    if A(l,3)==A(l+1,3) && A(l,4)==A(l+1,4) && A(l,5)==A(l+1,5) && A(l,6)==A(l+1,6)
        A(l+1,10)= ID_similaire
    else
        ID_similaire=ID_similaire+1
        A(l+1,10)= ID_similaire
    end
end
ID_similaire=1
for l=1:length(B)-1
    if B(l,3)==B(l+1,3) && B(l,4)==B(l+1,4) && B(l,5)==B(l+1,5) && B(l,6)==B(l+1,6)
        B(l+1,10)= ID_similaire
    else
        ID_similaire=ID_similaire+1
        B(l+1,10)= ID_similaire
    end
end

Combinaision_Unique_A=unique(A(:,10),'rows');
Combinaision_Unique_B=unique(B(:,10),'rows');

Taux_de_detour=size(Combinaision_Unique_A,1)/size(Combinaision_Unique_B,1);
disp ('Le taux de détour est:') 
disp(Taux_de_detour)


%% Exportation 

Fich_txt=Fich_txt(:,1:6);

writetable(Fich_txt,'MatrixTC_Nettoye.txt','Delimiter','\t');