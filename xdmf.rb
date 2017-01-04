class Xdmf < Formula
  desc "Extensible data model and format library"
  homepage "http://xdmf.org"
  head "https://gitlab.kitware.com/xdmf/xdmf.git"

  depends_on "boost" => :build
  depends_on "cmake" => :build
  depends_on "swig" => :build
  depends_on "homebrew/science/hdf5"
  depends_on "libtiff"

  # https://gitlab.kitware.com/xdmf/xdmf/merge_requests/24
  patch :DATA
  # A patch to make xdmf python3 compatible
  patch do
    url "https://sources.debian.net/data/main/x/xdmf/3.0+git20160803-2/debian/patches/python3.patch"
    sha256 "a3d07d0fdffd0bdaa4afc1a683071fb64385f65c6662163cf2096c2b059e71a5"
  end
  puts "I did a thing"

  def install
    ENV["XDMF_INSTALL_DIR"] = prefix
    ENV["HDF5_ROOT"] = Formula["hdf5"].opt_prefix
    mkdir "build" do
      system "cmake", "..", "-DBUILD_SHARED_LIBS=1", "-DXDMF_WRAP_PYTHON=1", *std_cmake_args
      system "make", "install"
    end
    (lib/"python2.7/site-packages").install Dir[lib/"python/*"]
  end

  test do
    system "python", "-c", "import Xdmf"
    system "echo","test"
  end
end
__END__
diff --git a/CMakeLists.txt b/CMakeLists.txt
index c22b94e..248284f 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -166,7 +166,13 @@ if(XDMF_WRAP_PYTHON)
     set_source_files_properties(${python_name}.i PROPERTIES CPLUSPLUS ON)
     set(swig_extra_generated_files "")
     swig_add_module(${python_name}Python python ${python_name}.i)
-    swig_link_libraries(${python_name}Python ${python_name} ${PYTHON_LIBRARIES})
+
+    if (NOT APPLE)
+      swig_link_libraries(${python_name}Python ${python_name} ${PYTHON_LIBRARIES})
+		else ()
+			swig_link_libraries(${python_name}Python ${python_name})
+    endif ()
+
     set_property(DIRECTORY APPEND PROPERTY
       ADDITIONAL_MAKE_CLEAN_FILES
       ${CMAKE_CURRENT_BINARY_DIR}/${python_name}.pyc
@@ -188,6 +194,12 @@ if(XDMF_WRAP_PYTHON)
       endif()
     endif()

+    if(APPLE)
+      set_target_properties(${SWIG_MODULE_${python_name}Python_REAL_NAME}
+        PROPERTIES
+        LINK_FLAGS "-undefined dynamic_lookup")
+    endif()
+
     set_target_properties(${SWIG_MODULE_${python_name}Python_REAL_NAME}
       PROPERTIES
       OUTPUT_NAME "_${python_name}")
