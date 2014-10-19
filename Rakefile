task :knit do
  sh "Rscript knit-all.r"
end

task :knitall do
  sh "Rscript knit-all.r --all"
end

task :build => [:knit] do
  sh "bundle exec jekyll build"
end

task :serve do
  sh "bundle exec jekyll serve"
end