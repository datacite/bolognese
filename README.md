[![Build Status](https://travis-ci.org/datacite/bolognese.svg?branch=master)](https://travis-ci.org/datacite/bolognese)
[![Code Climate](https://codeclimate.com/github/datacite/bolognese/badges/gpa.svg)](https://codeclimate.com/github/datacite/bolognese)
[![Test Coverage](https://codeclimate.com/github/datacite/bolognese/badges/coverage.svg)](https://codeclimate.com/github/datacite/bolognese/coverage)

# Bolognese

Ruby gem and command-line utility for conversion of DOI metadata from and to [schema.org](https://schema.org) in JSON-LD.

## Features

* convert [Crossref XML](https://support.crossref.org/hc/en-us/articles/214936283-UNIXREF-query-output-format) to schema.org/JSON-LD
* convert [DataCite XML](http://schema.datacite.org/) to schema.org/JSON-LD
* fetch schema.org/JSON-LD from a URL
* convert schema.org/JSON-LD to [DataCite XML](http://schema.datacite.org/)
* convert Crossref XML to [DataCite XML](http://schema.datacite.org/)

Conversion to Crossref XML is not yet supported.

## Installation

The usual way with Bundler: add the following to your `Gemfile` to install the
current version of the gem:

```ruby
gem 'bolognese'
```

Then run `bundle install` to install into your environment.

You can also install the gem system-wide in the usual way:

```bash
gem install bolognese
```

## Commands

The `bolognese` commands understand URLs and DOIs as arguments. The `--as` command
line flag sets the format, either `crossref`, `datacite`, or `schema_org` (default).

## Examples

Read Crossref XML:
```
bolognese read https://doi.org/10.7554/elife.01567 --as crossref

<?xml version="1.0" encoding="UTF-8"?>
<doi_records>
  <doi_record owner="10.7554" timestamp="2015-08-11 07:35:02">
    <crossref>
      <journal>
        <journal_metadata language="en">
          <full_title>eLife</full_title>
          <issn media_type="electronic">2050-084X</issn>
        </journal_metadata>
        <journal_issue>
          <publication_date media_type="online">
            <month>02</month>
            <day>11</day>
            <year>2014</year>
          </publication_date>
          <journal_volume>
            <volume>3</volume>
          </journal_volume>
        </journal_issue>
        <journal_article publication_type="full_text">
          <titles>
            <title>Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth</title>
          </titles>
          <contributors>
            <person_name contributor_role="author" sequence="first">
              <given_name>Martial</given_name>
              <surname>Sankar</surname>
            </person_name>
            <person_name contributor_role="author" sequence="additional">
              <given_name>Kaisa</given_name>
              <surname>Nieminen</surname>
            </person_name>
            <person_name contributor_role="author" sequence="additional">
              <given_name>Laura</given_name>
              <surname>Ragni</surname>
            </person_name>
            <person_name contributor_role="author" sequence="additional">
              <given_name>Ioannis</given_name>
              <surname>Xenarios</surname>
            </person_name>
            <person_name contributor_role="author" sequence="additional">
              <given_name>Christian S</given_name>
              <surname>Hardtke</surname>
            </person_name>
          </contributors>
          <publication_date media_type="online">
            <month>02</month>
            <day>11</day>
            <year>2014</year>
          </publication_date>
          <publisher_item>
            <identifier id_type="doi">10.7554/eLife.01567</identifier>
          </publisher_item>
          <crossmark>
            <crossmark_version>1</crossmark_version>
            <crossmark_policy>eLifesciences</crossmark_policy>
            <crossmark_domains>
              <crossmark_domain>
                <domain>www.elifesciences.org</domain>
              </crossmark_domain>
            </crossmark_domains>
            <crossmark_domain_exclusive>false</crossmark_domain_exclusive>
            <custom_metadata>
              <assertion name="received" label="Received" group_name="publication_history" group_label="Publication History" order="0">2013-09-20</assertion>
              <assertion name="accepted" label="Accepted" group_name="publication_history" group_label="Publication History" order="1">2013-12-24</assertion>
              <assertion name="published" label="Published" group_name="publication_history" group_label="Publication History" order="2">2014-02-11</assertion>
              <program name="fundref">
                <assertion name="fundgroup">
                  <assertion name="funder_name">SystemsX</assertion>
                </assertion>
                <assertion name="fundgroup">
                  <assertion name="funder_name">
                    EMBO
                    <assertion name="funder_identifier">http://dx.doi.org/10.13039/501100003043</assertion>
                  </assertion>
                </assertion>
                <assertion name="fundgroup">
                  <assertion name="funder_name">
                    Swiss National Science Foundation
                    <assertion name="funder_identifier">http://dx.doi.org/10.13039/501100001711</assertion>
                  </assertion>
                </assertion>
                <assertion name="fundgroup">
                  <assertion name="funder_name">
                    University of Lausanne
                    <assertion name="funder_identifier" provider="crossref">http://dx.doi.org/10.13039/501100006390</assertion>
                  </assertion>
                </assertion>
              </program>
              <program name="AccessIndicators">
                <license_ref applies_to="vor">http://creativecommons.org/licenses/by/3.0/</license_ref>
                <license_ref applies_to="am">http://creativecommons.org/licenses/by/3.0/</license_ref>
                <license_ref applies_to="tdm">http://creativecommons.org/licenses/by/3.0/</license_ref>
              </program>
            </custom_metadata>
          </crossmark>
          <doi_data>
            <doi>10.7554/eLife.01567</doi>
            <resource>http://elifesciences.org/lookup/doi/10.7554/eLife.01567</resource>
          </doi_data>
          <citation_list>
            <citation key="1">
              <journal_title>Nature</journal_title>
              <author>Bonke</author>
              <volume>426</volume>
              <first_page>181</first_page>
              <cYear>2003</cYear>
              <doi>10.1038/nature02100</doi>
            </citation>
            <citation key="2">
              <journal_title>Genetics</journal_title>
              <author>Brenner</author>
              <volume>182</volume>
              <first_page>413</first_page>
              <cYear>2009</cYear>
              <doi>10.1534/genetics.109.104976</doi>
            </citation>
            <citation key="3">
              <journal_title>Physiologia Plantarum</journal_title>
              <author>Chaffey</author>
              <volume>114</volume>
              <first_page>594</first_page>
              <cYear>2002</cYear>
              <doi>10.1034/j.1399-3054.2002.1140413.x</doi>
            </citation>
            <citation key="4">
              <journal_title>Neural computation</journal_title>
              <author>Chang</author>
              <volume>13</volume>
              <first_page>2119</first_page>
              <cYear>2001</cYear>
              <doi>10.1162/089976601750399335</doi>
            </citation>
            <citation key="5">
              <journal_title>Machine Learning</journal_title>
              <author>Cortes</author>
              <volume>20</volume>
              <first_page>273</first_page>
              <cYear>1995</cYear>
            </citation>
            <citation key="6">
              <journal_title>Development</journal_title>
              <author>Dolan</author>
              <volume>119</volume>
              <first_page>71</first_page>
              <cYear>1993</cYear>
            </citation>
            <citation key="7">
              <journal_title>Seminars in Cell &amp; Developmental Biology</journal_title>
              <author>Elo</author>
              <volume>20</volume>
              <first_page>1097</first_page>
              <cYear>2009</cYear>
              <doi>10.1016/j.semcdb.2009.09.009</doi>
            </citation>
            <citation key="8">
              <journal_title>Development</journal_title>
              <author>Etchells</author>
              <volume>140</volume>
              <first_page>2224</first_page>
              <cYear>2013</cYear>
              <doi>10.1242/dev.091314</doi>
            </citation>
            <citation key="9">
              <journal_title>PLOS Genetics</journal_title>
              <author>Etchells</author>
              <volume>8</volume>
              <first_page>e1002997</first_page>
              <cYear>2012</cYear>
              <doi>10.1371/journal.pgen.1002997</doi>
            </citation>
            <citation key="10">
              <journal_title>Molecular Systems Biology</journal_title>
              <author>Fuchs</author>
              <volume>6</volume>
              <first_page>370</first_page>
              <cYear>2010</cYear>
              <doi>10.1038/msb.2010.25</doi>
            </citation>
            <citation key="11">
              <journal_title>Bio Systems</journal_title>
              <author>Granqvist</author>
              <volume>110</volume>
              <first_page>60</first_page>
              <cYear>2012</cYear>
              <doi>10.1016/j.biosystems.2012.07.004</doi>
            </citation>
            <citation key="12">
              <journal_title>Current Opinion in Plant Biology</journal_title>
              <author>Groover</author>
              <volume>9</volume>
              <first_page>55</first_page>
              <cYear>2006</cYear>
              <doi>10.1016/j.pbi.2005.11.013</doi>
            </citation>
            <citation key="13">
              <journal_title>Plant Cell</journal_title>
              <author>Hirakawa</author>
              <volume>22</volume>
              <first_page>2618</first_page>
              <cYear>2010</cYear>
              <doi>10.1105/tpc.110.076083</doi>
            </citation>
            <citation key="14">
              <journal_title>Proceedings of the National Academy of Sciences of the United States of America</journal_title>
              <author>Hirakawa</author>
              <volume>105</volume>
              <first_page>15208</first_page>
              <cYear>2008</cYear>
              <doi>10.1073/pnas.0808444105</doi>
            </citation>
            <citation key="15">
              <journal_title>Cell</journal_title>
              <author>Meyerowitz</author>
              <volume>56</volume>
              <first_page>263</first_page>
              <cYear>1989</cYear>
              <doi>10.1016/0092-8674(89)90900-8</doi>
            </citation>
            <citation key="16">
              <journal_title>Science</journal_title>
              <author>Meyerowitz</author>
              <volume>295</volume>
              <first_page>1482</first_page>
              <cYear>2002</cYear>
              <doi>10.1126/science.1066609</doi>
            </citation>
            <citation key="17">
              <journal_title>Plant Physiol</journal_title>
              <author>Nieminen</author>
              <volume>135</volume>
              <first_page>653</first_page>
              <cYear>2004</cYear>
              <doi>10.1104/pp.104.040212</doi>
            </citation>
            <citation key="18">
              <journal_title>Nature Biotechnology</journal_title>
              <author>Noble</author>
              <volume>24</volume>
              <first_page>1565</first_page>
              <cYear>2006</cYear>
              <doi>10.1038/nbt1206-1565</doi>
            </citation>
            <citation key="19">
              <journal_title>Proceedings of the National Academy of Sciences of the United States of America</journal_title>
              <author>Olson</author>
              <volume>77</volume>
              <first_page>1516</first_page>
              <cYear>1980</cYear>
              <doi>10.1073/pnas.77.3.1516</doi>
            </citation>
            <citation key="20">
              <journal_title>Bioinformatics</journal_title>
              <author>Pau</author>
              <volume>26</volume>
              <first_page>979</first_page>
              <cYear>2010</cYear>
              <doi>10.1093/bioinformatics/btq046</doi>
            </citation>
            <citation key="21">
              <journal_title>Plant Cell</journal_title>
              <author>Ragni</author>
              <volume>23</volume>
              <first_page>1322</first_page>
              <cYear>2011</cYear>
              <doi>10.1105/tpc.111.084020</doi>
            </citation>
            <citation key="22">
              <author>Sankar</author>
              <cYear>2014</cYear>
              <doi>10.5061/dryad.b835k</doi>
            </citation>
            <citation key="23">
              <journal_title>Current Biology</journal_title>
              <author>Sibout</author>
              <volume>18</volume>
              <first_page>458</first_page>
              <cYear>2008</cYear>
              <doi>10.1016/j.cub.2008.02.070</doi>
            </citation>
            <citation key="24">
              <journal_title>The New Phytologist</journal_title>
              <author>Spicer</author>
              <volume>186</volume>
              <first_page>577</first_page>
              <cYear>2010</cYear>
              <doi>10.1111/j.1469-8137.2010.03236.x</doi>
            </citation>
            <citation key="25">
              <journal_title>Machine Vision and Applications</journal_title>
              <author>Theriault</author>
              <volume>23</volume>
              <first_page>659</first_page>
              <cYear>2012</cYear>
              <doi>10.1007/s00138-011-0345-9</doi>
            </citation>
            <citation key="26">
              <journal_title>Cell</journal_title>
              <author>Uyttewaal</author>
              <volume>149</volume>
              <first_page>439</first_page>
              <cYear>2012</cYear>
              <doi>10.1016/j.cell.2012.02.048</doi>
            </citation>
            <citation key="27">
              <journal_title>Nature Cell Biology</journal_title>
              <author>Yin</author>
              <volume>15</volume>
              <first_page>860</first_page>
              <cYear>2013</cYear>
              <doi>10.1038/ncb2764</doi>
            </citation>
          </citation_list>
          <component_list>
            <component parent_relation="isPartOf">
              <titles>
                <title>
                  <b>Abstract</b>
                </title>
              </titles>
              <format mime_type="text/plain" />
              <doi_data>
                <doi>10.7554/eLife.01567.001</doi>
                <resource>http://elifesciences.org/lookup/doi/10.7554/eLife.01567.001</resource>
              </doi_data>
            </component>
            <component parent_relation="isPartOf">
              <titles>
                <title>
                  <b>eLife digest</b>
                </title>
              </titles>
              <format mime_type="text/plain" />
              <doi_data>
                <doi>10.7554/eLife.01567.002</doi>
                <resource>http://elifesciences.org/lookup/doi/10.7554/eLife.01567.002</resource>
              </doi_data>
            </component>
            <component parent_relation="isPartOf">
              <titles>
                <title>Figure 1. Cellular level analysis of Arabidopsis hypocotyl secondary growth.</title>
                <subtitle>
                  (
                  <b>A</b>
                  ) Light microscopy of cross sections obtained from Arabidopsis hypocotyls (organ position illustrated for a 9-day-old seedling, lower left) at 9 dag (upper left) and 35 dag (right). Size bars are 100 μm. Blue GUS staining due to the presence of an
                  <i>APL::GUS</i>
                  reporter gene in this Col-0 background line marks phloem bundles. (
                  <b>B</b>
                  ) Overview of the developmental series (time points and distinct samples per genotype) analyzed in this study. (
                  <b>C</b>
                  ) Example of a high-resolution hypocotyl section image assembled from 11 × 11 tiles. (
                  <b>D</b>
                  ) The same image after pre-processing and binarization, and (
                  <b>E</b>
                  ) subsequent segmentation using a watershed algorithm. (
                  <b>F</b>
                  ) Number of mis-segmented cells as determined by careful visual inspection in 12 sections, plotted against the total number of cells per section (log scale).
                </subtitle>
              </titles>
              <format mime_type="image/tiff" />
              <doi_data>
                <doi>10.7554/eLife.01567.003</doi>
                <resource>http://elifesciences.org/lookup/doi/10.7554/eLife.01567.003</resource>
              </doi_data>
            </component>
            <component parent_relation="isPartOf">
              <titles>
                <title>Figure 2. The ‘Quantitative Histology’ approach.</title>
                <subtitle>
                  (
                  <b>A</b>
                  ) Overview of the computational pipeline from image acquisition to analysis. (
                  <b>B</b>
                  ) ‘Phenoprints’ for the different genotypes and developmental stages.
                </subtitle>
              </titles>
              <format mime_type="image/tiff" />
              <doi_data>
                <doi>10.7554/eLife.01567.004</doi>
                <resource>http://elifesciences.org/lookup/doi/10.7554/eLife.01567.004</resource>
              </doi_data>
            </component>
            <component parent_relation="isPartOf">
              <titles>
                <title>Figure 2—figure supplement 1. An example of classifier selection through V-fold cross validation.</title>
                <subtitle>The green arrow points out the selected feature combination according to the criteria of minimum number of features with the highest performance and the lowest variation (the radiusV feature was excluded due to its putative variation in tissue location).</subtitle>
              </titles>
              <format mime_type="image/tiff" />
              <doi_data>
                <doi>10.7554/eLife.01567.005</doi>
                <resource>http://elifesciences.org/lookup/doi/10.7554/eLife.01567.005</resource>
              </doi_data>
            </component>
            <component parent_relation="isPartOf">
              <titles>
                <title>Figure 3. Progression of tissue proliferation.</title>
                <subtitle>
                  (
                  <b>A</b>
                  ) Principal component analysis (PCA) of the phenoprints shown in Figure 2B, performed with normalized values (Supplementary file 4). The inlay screeplot displays the proportion of total variation explained by each principal component. (
                  <b>B–E</b>
                  ) Comparative plots of parameter progression in the two genotypes. In (
                  <b>D</b>
                  ), xylem represents combined vessel, parenchyma, and fiber cells, phloem represents combined phloem parenchyma and bundle cells. Error bars indicate standard error.
                </subtitle>
              </titles>
              <format mime_type="image/tiff" />
              <doi_data>
                <doi>10.7554/eLife.01567.006</doi>
                <resource>http://elifesciences.org/lookup/doi/10.7554/eLife.01567.006</resource>
              </doi_data>
            </component>
            <component parent_relation="isPartOf">
              <titles>
                <title>Figure 4. Bimodal distribution of incline angle according to position.</title>
                <subtitle>
                  (
                  <b>A</b>
                  and
                  <b>B</b>
                  ) Spatial distribution of cell incline angle illustrates the vascular organization in Ler (
                  <b>B</b>
                  ) as compared to Col-0 (
                  <b>A</b>
                  ) at later stages of development, for example 30 dag. The size of the disc increases with the area of the cell. Blue color indicates radial cell orientation, red orthoradial. (
                  <b>C</b>
                  and
                  <b>D</b>
                  ) Violin plots of incline angle distribution, illustrating increasingly bimodal distribution coincident with refined vascular organization and different dynamics of the process in the two genotypes.
                </subtitle>
              </titles>
              <format mime_type="image/tiff" />
              <doi_data>
                <doi>10.7554/eLife.01567.007</doi>
                <resource>http://elifesciences.org/lookup/doi/10.7554/eLife.01567.007</resource>
              </doi_data>
            </component>
            <component parent_relation="isPartOf">
              <titles>
                <title>Figure 4—figure supplement 1. An illustration of the incline angle.</title>
                <subtitle>The incline is the angle between the section radius through the center of an ellipse fit to a cell and the major axis of that ellipse extended towards the x axis.</subtitle>
              </titles>
              <format mime_type="image/tiff" />
              <doi_data>
                <doi>10.7554/eLife.01567.008</doi>
                <resource>http://elifesciences.org/lookup/doi/10.7554/eLife.01567.008</resource>
              </doi_data>
            </component>
            <component parent_relation="isPartOf">
              <titles>
                <title>Figure 5. Distinct local organization of incline angle during hypocotyl secondary growth progression.</title>
                <subtitle>
                  (
                  <b>A</b>
                  –
                  <b>J</b>
                  ) Density plots of cell incline angle vs radial position for the two genotypes at the indicated developmental stages, representing all cells across all sections for a given time point. The red lines represent the fit of these cloud distributions with locally weighted linear regression (i.e., lowess), revealing the essential data trends. All sections were normalized from 0.0 (the manually defined center) to 1.0 (the average radius in a set of sections as determined by the average distance of the outermost cells from the center for individual sections). Box plots indicate the quartiles of the radian distribution for each cell-type class and are placed at the average position of the cell type with respect to the y axis. Outliers are shown as circles.
                </subtitle>
              </titles>
              <format mime_type="image/tiff" />
              <doi_data>
                <doi>10.7554/eLife.01567.009</doi>
                <resource>http://elifesciences.org/lookup/doi/10.7554/eLife.01567.009</resource>
              </doi_data>
            </component>
            <component parent_relation="isPartOf">
              <titles>
                <title>Figure 5—figure supplement 1. Analysis of cell number in defined xylem regions of different size.</title>
                <subtitle>Cell number in a circle of 200–500 pixels around the section centers for Col-0. Cell count in a constant area of xylem over time across all averaged across all sections.</subtitle>
              </titles>
              <format mime_type="image/tiff" />
              <doi_data>
                <doi>10.7554/eLife.01567.010</doi>
                <resource>http://elifesciences.org/lookup/doi/10.7554/eLife.01567.010</resource>
              </doi_data>
            </component>
            <component parent_relation="isPartOf">
              <titles>
                <title>Figure 6. Mapping of phloem pole patterning.</title>
                <subtitle>
                  (
                  <b>A</b>
                  ) Example of Gaussian kernel density estimate of the location of predicted phloem bundles cells in a 30 dag Col-0 section. High density represents phloem poles. (
                  <b>B</b>
                  ) Example of an analysis of emerging phloem pole position in a 30 dag Col-0 section. The plot represents a pixel intensity map after noise reduction along a circular region of interest across the emerging phloem poles. Intensity peaks are due to GUS staining conferred to phloem bundles by an
                  <i>APL::GUS</i>
                  reporter construct. (
                  <b>C</b>
                  ) Probability density function of the data shown in (
                  <b>B</b>
                  ) obtained from an automated Bayesian model. The dominant single peak indicates a constant arc distance of ca. 62 pixel between the phloem poles.
                </subtitle>
              </titles>
              <format mime_type="image/tiff" />
              <doi_data>
                <doi>10.7554/eLife.01567.011</doi>
                <resource>http://elifesciences.org/lookup/doi/10.7554/eLife.01567.011</resource>
              </doi_data>
            </component>
            <component parent_relation="isReferencedBy">
              <titles>
                <title>
                  Supplementary file 1. (
                  <b>A</b>
                  ) An explanation of the extracted parameters that describe the cellular features. (
                  <b>B</b>
                  ) Summary information of the hand-labeled training set for supervised machine learning. (
                  <b>C</b>
                  ) Definition of the classifiers selected for analysis. (
                  <b>D</b>
                  ) Summary of the classifier parameters for supervised machine learning. (
                  <b>E</b>
                  ) Overview of the cell type classes recognized by the supervised machine learning approach and their assignment codes used in Data Files 3 and 4.
                </title>
              </titles>
              <format mime_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" />
              <doi_data>
                <doi>10.7554/eLife.01567.012</doi>
                <resource>http://elifesciences.org/lookup/doi/10.7554/eLife.01567.012</resource>
              </doi_data>
            </component>
            <component parent_relation="isReferencedBy">
              <titles>
                <title>Supplementary file 2. Quality control files for the Col-0 sections.</title>
              </titles>
              <format mime_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" />
              <doi_data>
                <doi>10.7554/eLife.01567.013</doi>
                <resource>http://elifesciences.org/lookup/doi/10.7554/eLife.01567.013</resource>
              </doi_data>
            </component>
            <component parent_relation="isReferencedBy">
              <titles>
                <title>Supplementary file 3. Quality control files for the Ler sections.</title>
              </titles>
              <format mime_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" />
              <doi_data>
                <doi>10.7554/eLife.01567.014</doi>
                <resource>http://elifesciences.org/lookup/doi/10.7554/eLife.01567.014</resource>
              </doi_data>
            </component>
            <component parent_relation="isReferencedBy">
              <titles>
                <title>Supplementary file 4. The normalized values of the phenoprints (Figure 2B) used for PCA.</title>
              </titles>
              <format mime_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" />
              <doi_data>
                <doi>10.7554/eLife.01567.015</doi>
                <resource>http://elifesciences.org/lookup/doi/10.7554/eLife.01567.015</resource>
              </doi_data>
            </component>
            <component parent_relation="isPartOf">
              <titles>
                <title>
                  <b>Decision letter</b>
                </title>
              </titles>
              <format mime_type="text/plain" />
              <doi_data>
                <doi>10.7554/eLife.01567.016</doi>
                <resource>http://elifesciences.org/lookup/doi/10.7554/eLife.01567.016</resource>
              </doi_data>
            </component>
            <component parent_relation="isPartOf">
              <titles>
                <title>
                  <b>Author response</b>
                </title>
              </titles>
              <format mime_type="text/plain" />
              <doi_data>
                <doi>10.7554/eLife.01567.017</doi>
                <resource>http://elifesciences.org/lookup/doi/10.7554/eLife.01567.017</resource>
              </doi_data>
            </component>
          </component_list>
        </journal_article>
      </journal>
    </crossref>
  </doi_record>
</doi_records>
```

Convert Crossref XML to schema.org/JSON-LD:
```
bolognese read https://doi.org/10.7554/elife.01567

{
    "@context": "http://schema.org",
    "@type": "ScholarlyArticle",
    "@id": "https://doi.org/10.7554/elife.01567",
    "url": "http://elifesciences.org/lookup/doi/10.7554/eLife.01567",
    "additionalType": "JournalArticle",
    "name": "Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth",
    "author": [{
        "@type": "Person",
        "givenName": "Martial",
        "familyName": "Sankar"
    }, {
        "@type": "Person",
        "givenName": "Kaisa",
        "familyName": "Nieminen"
    }, {
        "@type": "Person",
        "givenName": "Laura",
        "familyName": "Ragni"
    }, {
        "@type": "Person",
        "givenName": "Ioannis",
        "familyName": "Xenarios"
    }, {
        "@type": "Person",
        "givenName": "Christian S",
        "familyName": "Hardtke"
    }],
    "license": "http://creativecommons.org/licenses/by/3.0/",
    "datePublished": "2014-02-11",
    "dateModified": "2015-08-11T05:35:02Z",
    "isPartOf": {
        "@type": "Periodical",
        "name": "eLife",
        "issn": "2050-084X"
    },
    "citation": [{
        "@type": "CreativeWork",
        "@id": "https://doi.org/10.1038/nature02100",
        "position": "1",
        "datePublished": "2003"
    }, {
        "@type": "CreativeWork",
        "@id": "https://doi.org/10.1534/genetics.109.104976",
        "position": "2",
        "datePublished": "2009"
    }, {
        "@type": "CreativeWork",
        "@id": "https://doi.org/10.1034/j.1399-3054.2002.1140413.x",
        "position": "3",
        "datePublished": "2002"
    }, {
        "@type": "CreativeWork",
        "@id": "https://doi.org/10.1162/089976601750399335",
        "position": "4",
        "datePublished": "2001"
    }, {
        "@type": "CreativeWork",
        "position": "5",
        "datePublished": "1995"
    }, {
        "@type": "CreativeWork",
        "position": "6",
        "datePublished": "1993"
    }, {
        "@type": "CreativeWork",
        "@id": "https://doi.org/10.1016/j.semcdb.2009.09.009",
        "position": "7",
        "datePublished": "2009"
    }, {
        "@type": "CreativeWork",
        "@id": "https://doi.org/10.1242/dev.091314",
        "position": "8",
        "datePublished": "2013"
    }, {
        "@type": "CreativeWork",
        "@id": "https://doi.org/10.1371/journal.pgen.1002997",
        "position": "9",
        "datePublished": "2012"
    }, {
        "@type": "CreativeWork",
        "@id": "https://doi.org/10.1038/msb.2010.25",
        "position": "10",
        "datePublished": "2010"
    }, {
        "@type": "CreativeWork",
        "@id": "https://doi.org/10.1016/j.biosystems.2012.07.004",
        "position": "11",
        "datePublished": "2012"
    }, {
        "@type": "CreativeWork",
        "@id": "https://doi.org/10.1016/j.pbi.2005.11.013",
        "position": "12",
        "datePublished": "2006"
    }, {
        "@type": "CreativeWork",
        "@id": "https://doi.org/10.1105/tpc.110.076083",
        "position": "13",
        "datePublished": "2010"
    }, {
        "@type": "CreativeWork",
        "@id": "https://doi.org/10.1073/pnas.0808444105",
        "position": "14",
        "datePublished": "2008"
    }, {
        "@type": "CreativeWork",
        "@id": "https://doi.org/10.1016/0092-8674(89)90900-8",
        "position": "15",
        "datePublished": "1989"
    }, {
        "@type": "CreativeWork",
        "@id": "https://doi.org/10.1126/science.1066609",
        "position": "16",
        "datePublished": "2002"
    }, {
        "@type": "CreativeWork",
        "@id": "https://doi.org/10.1104/pp.104.040212",
        "position": "17",
        "datePublished": "2004"
    }, {
        "@type": "CreativeWork",
        "@id": "https://doi.org/10.1038/nbt1206-1565",
        "position": "18",
        "datePublished": "2006"
    }, {
        "@type": "CreativeWork",
        "@id": "https://doi.org/10.1073/pnas.77.3.1516",
        "position": "19",
        "datePublished": "1980"
    }, {
        "@type": "CreativeWork",
        "@id": "https://doi.org/10.1093/bioinformatics/btq046",
        "position": "20",
        "datePublished": "2010"
    }, {
        "@type": "CreativeWork",
        "@id": "https://doi.org/10.1105/tpc.111.084020",
        "position": "21",
        "datePublished": "2011"
    }, {
        "@type": "CreativeWork",
        "@id": "https://doi.org/10.5061/dryad.b835k",
        "position": "22",
        "datePublished": "2014"
    }, {
        "@type": "CreativeWork",
        "@id": "https://doi.org/10.1016/j.cub.2008.02.070",
        "position": "23",
        "datePublished": "2008"
    }, {
        "@type": "CreativeWork",
        "@id": "https://doi.org/10.1111/j.1469-8137.2010.03236.x",
        "position": "24",
        "datePublished": "2010"
    }, {
        "@type": "CreativeWork",
        "@id": "https://doi.org/10.1007/s00138-011-0345-9",
        "position": "25",
        "datePublished": "2012"
    }, {
        "@type": "CreativeWork",
        "@id": "https://doi.org/10.1016/j.cell.2012.02.048",
        "position": "26",
        "datePublished": "2012"
    }, {
        "@type": "CreativeWork",
        "@id": "https://doi.org/10.1038/ncb2764",
        "position": "27",
        "datePublished": "2013"
    }],
    "funder": [{
        "@type": "Organization",
        "name": "SystemsX"
    }, {
        "@type": "Organization",
        "@id": "https://doi.org/10.13039/501100003043",
        "name": "EMBO"
    }, {
        "@type": "Organization",
        "@id": "https://doi.org/10.13039/501100001711",
        "name": "Swiss National Science Foundation"
    }, {
        "@type": "Organization",
        "@id": "https://doi.org/10.13039/501100006390",
        "name": "University of Lausanne"
    }],
    "provider": {
        "@type": "Organization",
        "name": "Crossref"
    }
}
```

Convert Crossref XML to DataCite XML:
```
bolognese read https://doi.org/10.7554/elife.01567 --as datacite

<?xml version="1.0" encoding="UTF-8"?>
<resource xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://datacite.org/schema/kernel-4" xsi:schemaLocation="http://datacite.org/schema/kernel-4 http://schema.datacite.org/meta/kernel-4/metadata.xsd">
  <identifier identifierType="DOI">10.7554/eLife.01567</identifier>
  <creators>
    <creator>
      <creatorName>Sankar, Martial</creatorName>
      <givenName>Martial</givenName>
      <familyName>Sankar</familyName>
    </creator>
    <creator>
      <creatorName>Nieminen, Kaisa</creatorName>
      <givenName>Kaisa</givenName>
      <familyName>Nieminen</familyName>
    </creator>
    <creator>
      <creatorName>Ragni, Laura</creatorName>
      <givenName>Laura</givenName>
      <familyName>Ragni</familyName>
    </creator>
    <creator>
      <creatorName>Xenarios, Ioannis</creatorName>
      <givenName>Ioannis</givenName>
      <familyName>Xenarios</familyName>
    </creator>
    <creator>
      <creatorName>Hardtke, Christian S</creatorName>
      <givenName>Christian S</givenName>
      <familyName>Hardtke</familyName>
    </creator>
  </creators>
  <titles>
    <title>Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth</title>
  </titles>
  <publisher>eLife</publisher>
  <publicationYear>2014</publicationYear>
  <resourceType resourceTypeGeneral="Text">JournalArticle</resourceType>
  <fundingReferences>
    <fundingReference>
      <funderName>SystemsX</funderName>
    </fundingReference>
    <fundingReference>
      <funderName>EMBO</funderName>
      <funderIdentifier funderIdentifierType="Crossref Funder ID">https://doi.org/10.13039/501100003043</funderIdentifier>
    </fundingReference>
    <fundingReference>
      <funderName>Swiss National Science Foundation</funderName>
      <funderIdentifier funderIdentifierType="Crossref Funder ID">https://doi.org/10.13039/501100001711</funderIdentifier>
    </fundingReference>
    <fundingReference>
      <funderName>University of Lausanne</funderName>
      <funderIdentifier funderIdentifierType="Crossref Funder ID">https://doi.org/10.13039/501100006390</funderIdentifier>
    </fundingReference>
  </fundingReferences>
  <dates>
    <date dateType="Issued">2014-02-11</date>
    <date dateType="Updated">2015-08-11T05:35:02Z</date>
  </dates>
  <relatedIdentifiers>
    <relatedIdentifier relatedIdentifierType="DOI" relationType="References">https://doi.org/10.1038/nature02100</relatedIdentifier>
    <relatedIdentifier relatedIdentifierType="DOI" relationType="References">https://doi.org/10.1534/genetics.109.104976</relatedIdentifier>
    <relatedIdentifier relatedIdentifierType="DOI" relationType="References">https://doi.org/10.1034/j.1399-3054.2002.1140413.x</relatedIdentifier>
    <relatedIdentifier relatedIdentifierType="DOI" relationType="References">https://doi.org/10.1162/089976601750399335</relatedIdentifier>
    <relatedIdentifier relatedIdentifierType="DOI" relationType="References">https://doi.org/10.1016/j.semcdb.2009.09.009</relatedIdentifier>
    <relatedIdentifier relatedIdentifierType="DOI" relationType="References">https://doi.org/10.1242/dev.091314</relatedIdentifier>
    <relatedIdentifier relatedIdentifierType="DOI" relationType="References">https://doi.org/10.1371/journal.pgen.1002997</relatedIdentifier>
    <relatedIdentifier relatedIdentifierType="DOI" relationType="References">https://doi.org/10.1038/msb.2010.25</relatedIdentifier>
    <relatedIdentifier relatedIdentifierType="DOI" relationType="References">https://doi.org/10.1016/j.biosystems.2012.07.004</relatedIdentifier>
    <relatedIdentifier relatedIdentifierType="DOI" relationType="References">https://doi.org/10.1016/j.pbi.2005.11.013</relatedIdentifier>
    <relatedIdentifier relatedIdentifierType="DOI" relationType="References">https://doi.org/10.1105/tpc.110.076083</relatedIdentifier>
    <relatedIdentifier relatedIdentifierType="DOI" relationType="References">https://doi.org/10.1073/pnas.0808444105</relatedIdentifier>
    <relatedIdentifier relatedIdentifierType="DOI" relationType="References">https://doi.org/10.1016/0092-8674(89)90900-8</relatedIdentifier>
    <relatedIdentifier relatedIdentifierType="DOI" relationType="References">https://doi.org/10.1126/science.1066609</relatedIdentifier>
    <relatedIdentifier relatedIdentifierType="DOI" relationType="References">https://doi.org/10.1104/pp.104.040212</relatedIdentifier>
    <relatedIdentifier relatedIdentifierType="DOI" relationType="References">https://doi.org/10.1038/nbt1206-1565</relatedIdentifier>
    <relatedIdentifier relatedIdentifierType="DOI" relationType="References">https://doi.org/10.1073/pnas.77.3.1516</relatedIdentifier>
    <relatedIdentifier relatedIdentifierType="DOI" relationType="References">https://doi.org/10.1093/bioinformatics/btq046</relatedIdentifier>
    <relatedIdentifier relatedIdentifierType="DOI" relationType="References">https://doi.org/10.1105/tpc.111.084020</relatedIdentifier>
    <relatedIdentifier relatedIdentifierType="DOI" relationType="References">https://doi.org/10.5061/dryad.b835k</relatedIdentifier>
    <relatedIdentifier relatedIdentifierType="DOI" relationType="References">https://doi.org/10.1016/j.cub.2008.02.070</relatedIdentifier>
    <relatedIdentifier relatedIdentifierType="DOI" relationType="References">https://doi.org/10.1111/j.1469-8137.2010.03236.x</relatedIdentifier>
    <relatedIdentifier relatedIdentifierType="DOI" relationType="References">https://doi.org/10.1007/s00138-011-0345-9</relatedIdentifier>
    <relatedIdentifier relatedIdentifierType="DOI" relationType="References">https://doi.org/10.1016/j.cell.2012.02.048</relatedIdentifier>
    <relatedIdentifier relatedIdentifierType="DOI" relationType="References">https://doi.org/10.1038/ncb2764</relatedIdentifier>
  </relatedIdentifiers>
  <rightsList>
    <rights rightsURI="http://creativecommons.org/licenses/by/3.0/">Creative Commons Attribution 3.0 (CC-BY 3.0)</rights>
  </rightsList>
</resource>
```

Read DataCite XML:
```
bolognese read 10.5061/DRYAD.8515 --as datacite

<?xml version="1.0" encoding="UTF-8"?>
<resource
    xmlns="http://datacite.org/schema/kernel-3"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:mets="http://www.loc.gov/METS/"
    xmlns:dspace="http://www.dspace.org/xmlns/dspace/dim"
    xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
    xmlns:dryad="http://purl.org/dryad/terms/"
    xsi:schemaLocation="http://datacite.org/schema/kernel-3 http://schema.datacite.org/meta/kernel-3/metadata.xsd">
    <identifier identifierType="DOI">10.5061/DRYAD.8515</identifier>
    <version>1</version>
    <creators>
        <creator>
            <creatorName>Ollomo, Benjamin</creatorName>
        </creator>
        <creator>
            <creatorName>Durand, Patrick</creatorName>
        </creator>
        <creator>
            <creatorName>Prugnolle, Franck</creatorName>
        </creator>
        <creator>
            <creatorName>Douzery, Emmanuel J. P.</creatorName>
        </creator>
        <creator>
            <creatorName>Arnathau, Céline</creatorName>
        </creator>
        <creator>
            <creatorName>Nkoghe, Dieudonné</creatorName>
        </creator>
        <creator>
            <creatorName>Leroy, Eric</creatorName>
        </creator>
        <creator>
            <creatorName>Renaud, François</creatorName>
        </creator>
    </creators>
    <titles>
        <title>Data from: A new malaria agent in African hominids.</title>
    </titles>
    <publisher>Dryad Digital Repository</publisher>
    <publicationYear>2011</publicationYear>
    <subjects>
        <subject>Phylogeny</subject>
        <subject>Malaria</subject>
        <subject>Parasites</subject>
        <subject>Taxonomy</subject>
        <subject>Mitochondrial genome</subject>
        <subject>Africa</subject>
        <subject>Plasmodium</subject>
    </subjects>
    <resourceType resourceTypeGeneral="Dataset">DataPackage</resourceType>
    <alternateIdentifiers>
        <alternateIdentifier alternateIdentifierType="citation">Ollomo B, Durand P, Prugnolle F, Douzery EJP, Arnathau C, Nkoghe D, Leroy E, Renaud F (2009) A new malaria agent in African hominids. PLoS Pathogens 5(5): e1000446.</alternateIdentifier>
    </alternateIdentifiers>
    <relatedIdentifiers>
        <relatedIdentifier relatedIdentifierType="DOI" relationType="HasPart">10.5061/DRYAD.8515/1</relatedIdentifier>
        <relatedIdentifier relatedIdentifierType="DOI" relationType="HasPart">10.5061/DRYAD.8515/2</relatedIdentifier>
        <relatedIdentifier relatedIdentifierType="DOI" relationType="IsReferencedBy">10.1371/JOURNAL.PPAT.1000446</relatedIdentifier>
        <relatedIdentifier relatedIdentifierType="PMID" relationType="IsReferencedBy">19478877</relatedIdentifier>
    </relatedIdentifiers>
    <rightsList>
        <rights rightsURI="http://creativecommons.org/publicdomain/zero/1.0/"/>
    </rightsList>
</resource>
```

Convert DataCite XML to schema.org/JSON-LD:
```sh
bolognese read 10.5061/DRYAD.8515

{
    "@context": "http://schema.org",
    "@type": "Dataset",
    "@id": "https://doi.org/10.5061/dryad.8515",
    "additionalType": "DataPackage",
    "name": "Data from: A new malaria agent in African hominids.",
    "alternateName": "Ollomo B, Durand P, Prugnolle F, Douzery EJP, Arnathau C, Nkoghe D, Leroy E, Renaud F (2009) A new malaria agent in African hominids. PLoS Pathogens 5(5): e1000446.",
    "author": [{
        "@type": "Person",
        "givenName": "Benjamin",
        "familyName": "Ollomo"
    }, {
        "@type": "Person",
        "givenName": "Patrick",
        "familyName": "Durand"
    }, {
        "@type": "Person",
        "givenName": "Franck",
        "familyName": "Prugnolle"
    }, {
        "@type": "Person",
        "givenName": "Emmanuel J. P.",
        "familyName": "Douzery"
    }, {
        "@type": "Person",
        "givenName": "Céline",
        "familyName": "Arnathau"
    }, {
        "@type": "Person",
        "givenName": "Dieudonné",
        "familyName": "Nkoghe"
    }, {
        "@type": "Person",
        "givenName": "Eric",
        "familyName": "Leroy"
    }, {
        "@type": "Person",
        "givenName": "François",
        "familyName": "Renaud"
    }],
    "license": "http://creativecommons.org/publicdomain/zero/1.0/",
    "version": "1",
    "keywords": "Phylogeny, Malaria, Parasites, Taxonomy, Mitochondrial genome, Africa, Plasmodium",
    "datePublished": "2011",
    "hasPart": [{
        "@type": "CreativeWork",
        "@id": "https://doi.org/10.5061/dryad.8515/1"
    }, {
        "@type": "CreativeWork",
        "@id": "https://doi.org/10.5061/dryad.8515/2"
    }],
    "citation": [{
        "@type": "CreativeWork",
        "@id": "https://doi.org/10.1371/journal.ppat.1000446"
    }],
    "schemaVersion": "http://datacite.org/schema/kernel-3",
    "publisher": {
        "@type": "Organization",
        "name": "Dryad Digital Repository"
    },
    "provider": {
        "@type": "Organization",
        "name": "DataCite"
    }
}
```

Convert DataCite XML to schema version 4.0:
```
bolognese read 10.5061/DRYAD.8515 --as datacite --schema_version http://datacite.org/schema/kernel-4

<?xml version="1.0" encoding="UTF-8"?>
<resource xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://datacite.org/schema/kernel-4" xsi:schemaLocation="http://datacite.org/schema/kernel-4 http://schema.datacite.org/meta/kernel-4/metadata.xsd">
  <identifier identifierType="DOI">10.5061/DRYAD.8515</identifier>
  <creators>
    <creator>
      <creatorName>Ollomo, Benjamin</creatorName>
      <givenName>Benjamin</givenName>
      <familyName>Ollomo</familyName>
    </creator>
    <creator>
      <creatorName>Durand, Patrick</creatorName>
      <givenName>Patrick</givenName>
      <familyName>Durand</familyName>
    </creator>
    <creator>
      <creatorName>Prugnolle, Franck</creatorName>
      <givenName>Franck</givenName>
      <familyName>Prugnolle</familyName>
    </creator>
    <creator>
      <creatorName>Douzery, Emmanuel J. P.</creatorName>
      <givenName>Emmanuel J. P.</givenName>
      <familyName>Douzery</familyName>
    </creator>
    <creator>
      <creatorName>Arnathau, Céline</creatorName>
      <givenName>Céline</givenName>
      <familyName>Arnathau</familyName>
    </creator>
    <creator>
      <creatorName>Nkoghe, Dieudonné</creatorName>
      <givenName>Dieudonné</givenName>
      <familyName>Nkoghe</familyName>
    </creator>
    <creator>
      <creatorName>Leroy, Eric</creatorName>
      <givenName>Eric</givenName>
      <familyName>Leroy</familyName>
    </creator>
    <creator>
      <creatorName>Renaud, François</creatorName>
      <givenName>François</givenName>
      <familyName>Renaud</familyName>
    </creator>
  </creators>
  <titles>
    <title>Data from: A new malaria agent in African hominids.</title>
  </titles>
  <publisher>Dryad Digital Repository</publisher>
  <publicationYear>2011</publicationYear>
  <resourceType resourceTypeGeneral="Dataset">DataPackage</resourceType>
  <alternateIdentifiers>
    <alternateIdentifier alternateIdentifierType="Local accession number">Ollomo B, Durand P, Prugnolle F, Douzery EJP, Arnathau C, Nkoghe D, Leroy E, Renaud F (2009) A new malaria agent in African hominids. PLoS Pathogens 5(5): e1000446.</alternateIdentifier>
  </alternateIdentifiers>
  <subjects>
    <subject>Phylogeny</subject>
    <subject>Malaria</subject>
    <subject>Parasites</subject>
    <subject>Taxonomy</subject>
    <subject>Mitochondrial genome</subject>
    <subject>Africa</subject>
    <subject>Plasmodium</subject>
  </subjects>
  <dates>
    <date dateType="Issued">2011</date>
  </dates>
  <relatedIdentifiers>
    <relatedIdentifier relatedIdentifierType="DOI" relationType="HasPart">https://doi.org/10.5061/dryad.8515/1</relatedIdentifier>
    <relatedIdentifier relatedIdentifierType="DOI" relationType="HasPart">https://doi.org/10.5061/dryad.8515/2</relatedIdentifier>
    <relatedIdentifier relatedIdentifierType="DOI" relationType="References">https://doi.org/10.1371/journal.ppat.1000446</relatedIdentifier>
  </relatedIdentifiers>
  <version>1</version>
  <rightsList>
    <rights rightsURI="http://creativecommons.org/publicdomain/zero/1.0/">Public Domain (CC0 1.0)</rights>
  </rightsList>
</resource>
```

Convert schema.org/JSON-LD to DataCite XML:

```
bolognese read https://blog.datacite.org/eating-your-own-dog-food --as datacite

<?xml version="1.0" encoding="UTF-8"?>
<resource xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://datacite.org/schema/kernel-4" xsi:schemaLocation="http://datacite.org/schema/kernel-4 http://schema.datacite.org/meta/kernel-4/metadata.xsd">
  <identifier identifierType="DOI">10.5438/4k3m-nyvg</identifier>
  <creators>
    <creator>
      <creatorName>Fenner, Martin</creatorName>
      <givenName>Martin</givenName>
      <familyName>Fenner</familyName>
      <nameIdentifier schemeURI="http://orcid.org/" nameIdentifierScheme="ORCID">http://orcid.org/0000-0003-1419-2405</nameIdentifier>
    </creator>
  </creators>
  <titles>
    <title>Eating your own Dog Food</title>
  </titles>
  <publisher>DataCite</publisher>
  <publicationYear>2016</publicationYear>
  <resourceType resourceTypeGeneral="Text">BlogPosting</resourceType>
  <alternateIdentifiers>
    <alternateIdentifier alternateIdentifierType="Local accession number">MS-49-3632-5083</alternateIdentifier>
  </alternateIdentifiers>
  <subjects>
    <subject>datacite</subject>
    <subject>doi</subject>
    <subject>metadata</subject>
    <subject>featured</subject>
  </subjects>
  <dates>
    <date dateType="Created">2016-12-20</date>
    <date dateType="Issued">2016-12-20</date>
    <date dateType="Updated">2016-12-20</date>
  </dates>
  <relatedIdentifiers>
    <relatedIdentifier relatedIdentifierType="DOI" relationType="IsPartOf">https://doi.org/10.5438/0000-00ss</relatedIdentifier>
    <relatedIdentifier relatedIdentifierType="DOI" relationType="References">https://doi.org/10.5438/0012</relatedIdentifier>
    <relatedIdentifier relatedIdentifierType="DOI" relationType="References">https://doi.org/10.5438/55e5-t5c0</relatedIdentifier>
  </relatedIdentifiers>
  <version>1.0</version>
  <rightsList>
    <rights rightsURI="https://creativecommons.org/licenses/by/4.0/"/>
  </rightsList>
  <descriptions>
    <description descriptionType="Abstract">Eating your own dog food is a slang term to describe that an organization should itself use the products and services it provides. For DataCite this means that we should use DOIs with appropriate metadata and strategies for long-term preservation for...</description>
  </descriptions>
</resource>
```

## Development

We use rspec for unit testing:

```
bundle exec rspec
```

Follow along via [Github Issues](https://github.com/datacite/bolognese/issues).
Please open an issue if conversion fails or metadata are not properly supported.

### Note on Patches/Pull Requests

* Fork the project
* Write tests for your new feature or a test that reproduces a bug
* Implement your feature or make a bug fix
* Do not mess with Rakefile, version or history
* Commit, push and make a pull request. Bonus points for topical branches.

## License
**bolognese** is released under the [MIT License](https://github.com/datacite/bolognese/blob/master/LICENSE.md).
