Pod::Spec.new do |s|
  s.name         = "LPImageGridView"
  s.version      = "0.0.1"
  s.summary      = "show images with grid view"
  s.description  = <<-DESC
                   show images with grid view which is based on flexiable UICollectionView with a fully customizable flowlayout
		 DESC

  s.homepage     = "https://github.com/litt1e-p/LPImageGridView"
  s.license          = { :type => 'MIT' }
  s.author           = { "litt1e-p" => "litt1e.p4ul@gmail.com"}
  s.source           = { :git => "https://github.com/litt1e-p/LPImageGridView.git", :tag => '0.0.1' }
  s.platform = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'LPImageGridView/*'
  s.dependency 'SDWebImage', '~> 4'
  s.dependency 'Masonry'
  s.frameworks = 'Foundation', 'UIKit'
end

