program test_dom_parseFile_spaces_1
 ! Regression test: parse a file whose absolute path contains a space.
 ! FoX runs the filename through its URI parser; a space is illegal in a URI
 ! path, so an absolute path such as macOS's ".../Application Support/..." used
 ! to fail with "not a valid URI" (or, in older builds, segfault). The file-open
 ! layer now percent-encodes the path and retries, so the file parses normally.
 use FoX_dom
 implicit none

 type(Node), pointer :: doc, b
 type(NodeList), pointer :: bList
 character(len=4096) :: cwd
 character(len=:), allocatable :: dir, path
 integer :: u

 ! Build an absolute path containing a space (a relative path does not trigger
 ! the bug, so the absolute form is essential here).
 call getcwd(cwd)
 dir = trim(cwd)//"/fox space dir"
 path = dir//"/spaced file.xml"

 call execute_command_line("rm -rf '"//dir//"'")
 call execute_command_line("mkdir -p '"//dir//"'")
 open(newunit=u, file=path, status="replace", action="write")
 write(u,'(a)') '<?xml version="1.0"?><a><b>hello world</b></a>'
 close(u)

 doc => parseFile(path)
 if (.not.associated(doc)) then
   write(*,'(a)') "FAILED: parseFile returned a null document"
 else
   bList => getElementsByTagname(doc, "b")
   if (getLength(bList) /= 1) then
     write(*,'(a)') "FAILED: expected exactly one <b> element"
   else
     b => item(bList, 0)
     write(*,'(a)') trim(getTextContent(b))
   end if
   call destroy(doc)
 end if

 call execute_command_line("rm -rf '"//dir//"'")

end program test_dom_parseFile_spaces_1
