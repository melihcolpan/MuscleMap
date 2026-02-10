Pod::Spec.new do |s|
  s.name         = "MuscleMap"
  s.version      = "1.6.0"
  s.summary      = "A SwiftUI SDK for rendering interactive human body muscle maps."
  s.description  = <<-DESC
    MuscleMap provides a declarative way to display a human body and visualize
    muscle data. Built entirely in SwiftUI with no external dependencies, it
    supports male and female body models, front and back views, tap/long-press/drag
    gestures, heatmap color scales, gradient fills, pulse animations, zoom,
    sub-group muscles, UIKit wrappers, accessibility, and localization (11 languages).
  DESC

  s.homepage     = "https://github.com/melihcolpan/MuscleMap"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Melih Colpan" => "melihcolpan@gmail.com" }

  s.ios.deployment_target = "17.0"
  s.osx.deployment_target = "14.0"
  s.swift_version = "5.9"

  s.source       = { :git => "https://github.com/melihcolpan/MuscleMap.git", :tag => s.version.to_s }
  s.source_files = "Sources/MuscleMap/**/*.swift"
  s.resources    = "Sources/MuscleMap/Resources/**/*.strings"

  s.frameworks   = "SwiftUI"
end
