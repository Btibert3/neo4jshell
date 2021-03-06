#' Remove subdirectory and all its contents from the Neo4J import directory
#'
#' @param local Logical indicating whether import is to a locally hosted or remotely hosted server.
#' @param con If remotely hosted server, list containing three objects: bolt address, uid, pwd as character strings providing connection to the Neo4J server
#' @param dir Character string of the Neo4J import subdirectory name to be deleted.
#' @param import_dir Character string of path to the Neo4J import directory.
#'
#' @return A success message if successful.  A error message otherwise.
#'
#' @examples
#' neo4j_rmdir(local = TRUE, dir = "mygraphdata", import_dir = path.expand("~/neo4j-community-3.5.8/import"))


neo4j_rmdir <- function (local = FALSE, con = list(address = NULL, uid = NULL, pwd = NULL), dir = NULL, import_dir = NULL) {

  if (substr(import_dir, nchar(import_dir), nchar(import_dir)) != "/") {
    import_dir <- paste0(import_dir, "/")
  }

  filestring <- paste0(import_dir, dir)
  tmp1 <- tempfile()

  if (!local) {

    ssh_uid <- paste0(con$uid, "@", basename(con$address))
    session <- ssh::ssh_connect(ssh_uid, passwd = con$pwd)
    output <- ssh::ssh_exec_wait(session, command = paste("rm -r", filestring), std_err = tmp1)
    ssh::ssh_disconnect(session)

  } else {

    if (.Platform$OS.type == "windows") {
      args <- c("/S", "/Q", filestring)
      output <- sys::exec_wait("rd", args = args, std_err = tmp1)
    } else {
      args <- c("-r", filestring)
      output <- sys::exec_wait("rm", args = args, std_err = tmp1)
    }
  }

  if (output == 0) {
    message("Directory and all contents removed successfuly!")
  } else {
    readLines(tmp1) %>% paste(collapse = " ") %>% noquote() %>% stop(call. = FALSE)
  }

}

