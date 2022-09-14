# Migrate a Google Doc (w/ Paperpile references) to Overleaf (LaTeX)

## Export document from Google Docs

1. Add-ons > Paperpile > Manage citations
2. {cog} > Export
3. Export document 
    * BibTeX citation codes
4. Export references
    * BibTeX

## Copy-paste from BibTeX Google Doc into Overleaf

	- Escape literals in the text 
		%	\%
	
	- insert Figure cross-references
	
		Figure 1	Figure \ref{fig:1}
		
	- use the right citation prefix
	
		\cite{					\citep{
		
		Name et al. \cite{		\cite{
		
		(e.g., \cite{
	

	- correct italicisation
	
		\textit{a priori}


	- search and replace all non-ascii chars

		[^\x00-\x7F]		


		≤	$\leq$
		

## Fix issues in the BibTeX references

	- upload "references.bib"  

	- fix bioRxiv preprints where the journal is "Cold Spring"
	  
	  journal       = "arXiv",
	  
	
	- every "@UNPUBLISHED" entry must have a note field

	  note     = "~",
	
	
	- resolve auto-conversion errors:
	
		% The entry below contains non-ASCII chars that could not be converted
		% to a LaTeX equivalent.
		
		- search and replace all non-ascii chars
	
			[^\x00-\x7F]


			~		\textasciitilde{}
			∼		\textasciitilde{}
			‐		-
			…		\ldots
			

## Export archive for upload to arXiv

- Overleaf Menu > Download > Source
    
- download the compiled version of the bibliography

    - Download PDF > output.bbl

    - rename `output.bbl` to `Article.bbl` and add to the zip file

- upload zip file to arXiv!!