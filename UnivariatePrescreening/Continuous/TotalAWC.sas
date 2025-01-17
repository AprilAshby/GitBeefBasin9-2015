/* Enter data */
data mydata;
	input Soil Shrub;
	cards;
71.54	1
31.306	1
34.989	1
50.615	1
57.516	2
37.851	2
45.525	1
36.305	1
93.268	2
55.884	2
42.348	3
81.54	1
53.071	1
48.307	1
69.349	1
34.916	1
47.73	1
32.369	2
52.835	1
45.857	1
58.627	1
84.195	1
35.632	3
82.921	2
54.454	1
40.915	1
37.08	1
24.95	1
31.598	3
9.155	1
11.687	2
25.42	1
61.993	1
19.619	2
28.046	1
41.77	2
11.687	3
31.485	1
33.838	1
32.559	2
48.3	3
56.263	1
44.477	1
10.431	1
32.369	1
9.155	1
39.118	1
68.27	3
38.657	1
58.26	2
46.633	3
51.002	1
19.117	1
57.362	1
17.59	1
46.634	1
110.484	2
27.855	1
30.112	1
40.92	1
49.647	1
33.854	1
38.416	1
19.728	2
12.848	1
42.971	1
9.155	2
31.448	1
38.451	1
33.119	1
36.62	2
23.008	1
53.795	1
24.691	1
38.82	3
33.976	1
37.355	3
40.345	1
23.428	3
45.533	2
45.212	3
29.615	3
30.617	3
20	2
42.414	1
48.131	3
36.35	1
37.513	1
43.331	2
24.208	1
67.765	2
74.972	1
63.818	1
33.796	2
21.133	3
41.108	1
47.135	1
51.488	1
;
run;

proc print data=mydata;
run;

/* Look at numerical data summaries */
proc means data=mydata mean;
	class Shrub;
	var Soil;
	title1 'Mean Comparison';
	title2 '(And number of experimental units per shrub class)';
run;

/* Fit model and check assumptions */
proc glm data=mydata plots=diagnostics;
	class Shrub;
	model Soil=Shrub;
	means Shrub / HOVtest=Levene;
	title1 'comparison of all shrub classes';
run;
