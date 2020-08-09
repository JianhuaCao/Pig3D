#!/usr/bin/env Rscript
# 
# Heatmap plot for counts
#
# Jianhua Cao @ HZAU
# Last modified: 2017-6-5
# Ver0.1
library("pheatmap")
library("RColorBrewer")
setwd(".")

infile = '3d4.rna.ZOOM.txt' # infile, csv, with header
df <- read.csv(infile, row.names = 1, check.names = F);head(df)
# ID,DEG,c1,c2,c3,t1,t2,t3
# ...

### heatmap input data ----
hmap_data = log1p(df[,2:7]) # data conversion for better plot
head(hmap_data)
cn <- colnames(hmap_data);cn
rn <- rownames(hmap_data);rn

### annotation col/row ----
ann_col = data.frame(Condition = factor(rep(c("CON", "TRT"), each = 3)))
rownames(ann_col) = cn;ann_col

ann_row = data.frame(Class = df$DEG)
rownames(ann_row) = rn;ann_row

# ann_row = data.frame(Class = factor(rep(c("DN","UP"),c(10,40))))
# rownames(ann_row) = rownames(hmap_data);ann_row

ann_color = list(
  Class = c(DN = "#7570B3", UP = "#E7298A"),
  Condition = c(CON = "burlywood", TRT = "cadetblue"));ann_color

# ---- Heatmap color ----
# YlOrRd, Reds, BuPu, YlGnBu
hmap_color = colorRampPalette(brewer.pal(9, "Blues"))(255)
# hmap_color = colorRampPalette(rev(brewer.pal(9, "Spectral")))(255)

# ---- Zoom in Heatmap plot ----
pheatmap(hmap_data, legend = T, color = hmap_color,
         cellwidth = 30, cellheight = 14, border_color = "white",

         annotation_col = ann_col,
         annotation_row = ann_row,
         annotation_colors = ann_color,

         # correlation,euclidean,maximum,manhattan,canberra,binary,minkowski
         cluster_rows = T,
         clustering_distance_rows = 'maximum',
         treeheight_row = 50,
         cutree_rows = 2,

         cluster_cols = F,
         clustering_distance_cols = 'canberra',
         treeheight_col = 30,
         # gaps_col = 3,

         show_rownames = T, fontsize_row = 8,
         show_colnames = T, fontsize_col = 16)


# sessionInfo()
