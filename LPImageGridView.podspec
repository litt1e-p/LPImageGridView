Pod::Spec.new do |s|
  s.name         = "LPImageGridView"
  s.version      = "0.0.3"
  s.summary      = "show images with grid view"
  s.description  = <<-DESC
                   show images with grid view which is based on flexiable UICollectionView with a fully customizable flowlayout
		 DESC

  s.homepage     = "https://github.com/litt1e-p/LPImageGridView"
  s.license          = { :type => 'MIT' }
  s.author           = { "litt1e-p" => "litt1e.p4ul@gmail.com"}
  s.source           = { :git => "https://github.com/litt1e-p/LPImageGridView.git", :tag => "#{s.version}" }
  s.platform = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'LPImageGridView/*'
  s.resources  = "LPImageGridView/*.bundle"
  s.dependency 'SDWebImage', '~> 4'
  s.dependency 'SDWebImage/GIF', '~> 4'
  s.dependency 'Masonry'
  s.frameworks = 'Foundation', 'UIKit'
end

