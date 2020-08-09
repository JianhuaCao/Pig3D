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

infile = '3d4.rna.DEG.txt' # infile, csv, with header
df <- read.csv(infile, row.names = 1, check.names = F);head(df)
# ID,c1,c2,c3,t1,t2,t3
# ...

# ---- heatmap input data ----
# hmap_data = df # original data
hmap_data = log1p(df[,1:6]) # data conversion for better plot
head(hmap_data)

# ---- annotation col/row
ann_col = data.frame(Condition = factor(rep(c("CON", "TRT"), each = 3)))
rownames(ann_col) = colnames(hmap_data);ann_col

# ann_row = data.frame(
#   Class = factor(rep(c("UP","DN"),c(40,10))))
# rownames(ann_row) = rownames(hmap_data);ann_row

ann_color = list(
  # Class = c(CON = "#FF0000", TRT = "#FFFFFF"),
  Condition = c(
    CON = "burlywood",
    TRT = "cadetblue"));ann_color

# ---- Heatmap color ----
# YlOrRd, Reds, BuPu, YlGnBu
hmap_color = colorRampPalette(brewer.pal(9, "Blues"))(255)
# hmap_color = colorRampPalette(rev(brewer.pal(9, "Spectral")))(255)

# "steelblue1", # seagreen, navy, white, forestgreen
# "yellow",   # yellow, white,
# "red"       # firebrick3, steelblue, red
# hmap_color = colorRampPalette(c("seagreen", "yellow", "red"))(50)

# ---- Overview plot ----
pheatmap(hmap_data, legend = T, color = hmap_color,
         cellwidth = 20, cellheight = 0.4,
         border_color = NA,

         annotation_legend = T,
         annotation_col    = ann_col,
         annotation_colors = ann_color,

         # correlation,euclidean,maximum,manhattan,canberra,binary,minkowski
         cluster_rows = T,
         clustering_distance_rows = 'minkowski',
         treeheight_row = 50,

         cluster_cols = T,
         clustering_distance_cols = 'minkowski',
         treeheight_col = 30,

         show_rownames = F, fontsize_row = 8,
         show_colnames = T, fontsize_col = 16)

# sessionInfo()
