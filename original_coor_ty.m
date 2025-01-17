function [x,y,z,u,v,w,lar_x,lar_y,lar_z,lar_u,lar_v,lar_w]=original_coor_ty(timestep,start_z,max_z)

bead_tnxyz = evalin('base','bead_tnxyz');
%find start_num
n_row_idx = (bead_tnxyz(:,5) == max_z);
n_filtered = bead_tnxyz(n_row_idx,:);
start_num = min(n_filtered(:,2));
%find max_bead_num
n_row_idx = (bead_tnxyz(:,5) == start_z);
n_filtered = bead_tnxyz(n_row_idx,:);
max_bead_num = max(n_filtered(:,2));
% position 
number=((max_bead_num-start_num+1)-mod((max_bead_num-start_num+1),20))/20; 
Atemp=zeros(number,3);
Atemp2=zeros(number,3);
bead_num=1;
index_i=1;
for i=start_num:10:max_bead_num+1
%original
a1=get_bead_pos_ty(timestep, i);
Atemp(index_i, :) = a1;
%next
a2=get_bead_pos_ty(timestep+1,i);
Atemp2(index_i, :) = a2;

index_i=index_i+1;
end

ori=Atemp.';

next=Atemp2.';

%displacement
dis=next-ori;

dis2=dis;
x1=ori(1,:);
y1=ori(2,:);
z1=ori(3,:);
u1=dis2(1,:);
v1=dis2(2,:);
w1=dis2(3,:);

x = [];
y = [];
z = [];
u = [];
v = [];
w = [];
lar_x=[];
lar_y=[];
lar_z=[];

lar_u=[];
lar_v=[];
lar_w=[];

for i=1:number
    if  u1(i)^2+v1(i)^2+w1(i)^2 > 1
        lar_x=[lar_x x1(i)];
        lar_y=[lar_y y1(i)];
        lar_z=[lar_z z1(i)];
        lar_u=[lar_u u1(i)];
        lar_v=[lar_v v1(i)];
        lar_w=[lar_w w1(i)]; 
    else
        x=[x x1(i)]; 
        y=[y y1(i)];
        z=[z z1(i)];
        u=[u u1(i)];
        v=[v v1(i)];
        w=[w w1(i)]; 
    end
end

BG_matrix = imread('CELL/Cell_1_0.tif');
for k=1:169
    BG_matrix(:,:,k+1) = imread(sprintf('CELL/Cell_1_%d.tif', k));
end
BG_matrix = padarray(BG_matrix,[6,6,1],0);

erase1um = 1;
erase1umij = erase1um * 6;
for k=start_z+1:max_z+1
    for i=1:1002+6-erase1umij*3+1
        for j=1:1004+6-erase1umij*3+1
           if (sum(sum(sum(BG_matrix(i:i+erase1umij*3-1,j:j+erase1umij*3-1,k-erase1um:k+erase1um))))-sum(sum(sum(BG_matrix(i+erase1umij:i+erase1umij*2-1,j+erase1umij:j+erase1umij*2-1,k-erase1um+1:k+erase1um-1)))))==0
               if sum(sum(sum(BG_matrix(i:i+erase1umij*3-1,j:j+erase1umij*3-1,k-erase1um:k+erase1um)))) ~= 0
                   [k i j]
                   BG_matrix(i+erase1umij:i+erase1umij*2-1,j+erase1umij:j+erase1umij*2-1,k) = 0;
               end             
           end
       end
   end
end



X = [];
Y = [];
Z = [];
for ztmp = start_z:max_z
   I = BG_matrix(:,:,ztmp+1);
   for i = 1:1002
      for j = 1:1004
         if I(i,j) == 1
             %for conti = 0:7
                X(end+1) = i/6;
                Y(end+1) = j/6;
                Z(end+1) = ztmp;% + conti/8;
             %end
         end
      end
   end
end




% plot vector map
figure
small_move=quiver3(x,y,z,u,v,w,'color','green');
hold on
Lar_move=quiver3(lar_x,lar_y,lar_z,lar_u,lar_v,lar_w,'color','red');
hold on
scatter3(X,Y,Z,5,'.','blue');

end
