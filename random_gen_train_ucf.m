function [images, labels]=random_gen_train_ucf(batch)
    image_path='/home/peiyong/Work/Zenglin/caffe-szl/examples/crowd/data/ucf-cc-50/img';
    dmap_path='/home/peiyong/Work/Zenglin/caffe-szl/examples/crowd/data/ucf-cc-50/dmap';

    patch_num = 1200;
    data_size = 224;
    down_scale=8;
    dense_size = floor(data_size /down_scale);
    isflip=true;
    train_set=[11:20 21:30 31:40 41:50];%[1:10 11:20 21:30 31:40 41:50]
    %% create train set
    images=[];
    labels=[];
    k=1;
    img_index=1;
    for i = batch
        if(isflip)
            img_index = train_set(ceil(i/(patch_num*2)));
        else
            img_index = train_set(ceil(i/patch_num));
        end
        imgPath=fullfile(image_path,num2str(img_index,'%d.jpg'));
        dmapPath=fullfile(dmap_path,num2str(img_index,'%d.mat'));

        img = single(imread(imgPath))./255;
        img = single(cat(3, img, img, img));
        load(dmapPath);
        [h, w, c] = size(img);
        patch_x = randperm(h-data_size,1);
        patch_y = randperm(w-data_size,1);

        patch = img(patch_x:(patch_x+data_size-1), patch_y:(patch_y+data_size-1), :);
        patch_dense = dmap(patch_x:(patch_x+data_size-1), patch_y:(patch_y+data_size-1));

        patch_sum=sum(sum(patch_dense));
        p_max=max(patch_dense(:));
        p_min=min(patch_dense(:));
        if patch_sum ~=0
            patch_dense = (patch_dense - p_min)/(p_max - p_min);
        end       
        patch_dense = imresize(patch_dense, [dense_size, dense_size]);
        patch_dense = patch_dense*(p_max - p_min) + p_min;
        res_sum=sum(sum(patch_dense));
        if res_sum ~=0
            patch_dense = patch_dense*(patch_sum/res_sum);
        end
        
        
        patch_label = reshape(patch_dense, [1,dense_size*dense_size]);
        images(:,:,:,k)=single(patch);
        labels(1,1,:,k)= single(patch_label(:));
        
        if(isflip &&(randperm(2,1)-1))
            patch=fliplr(patch);
            patch_dense=fliplr(patch_dense);
            patch_label = reshape(patch_dense, [1,dense_size*dense_size]); 

            images(:,:,:,k)=single(patch);
            labels(1,1,:,k)= single(patch_label(:));
        end
        k=k+1;
    end
end