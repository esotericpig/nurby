#!/usr/bin/env ruby

###
# This file is part of nurby.
# Copyright (c) 2017 Jonathan Bradley Whited (@esotericpig)
# 
# nurby is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# nurby is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public License
# along with nurby.  If not, see <http://www.gnu.org/licenses/>.
###

###
# Exit codes come from curl's manpage (https://curl.haxx.se/docs/manpage.html).
###
module Nurby
  class ExitCode
    attr_reader :code
    attr_reader :descr
    
    def initialize(code,descr)
      @code = code
      @descr = descr
    end
  end
  
  module ExitCodes
    UNSUPPORTED_PROTOCOL = ExitCode.new(1,%q^Unsupported protocol. This build of curl has no support for this protocol.^)
    INIT_FAILED = ExitCode.new(2,%q^Failed to initialize.^)
    MALFORMED_URL = ExitCode.new(3,%q^URL malformed. The syntax was not correct.^)
    MISSING_FEATURE = ExitCode.new(4,%q^A feature or option that was needed to perform the desired request was not enabled or was explicitly disabled at build-time. To make curl able to do this, you probably need another build of libcurl!^)
    UNRESOLVED_PROXY = ExitCode.new(5,%q^Couldn't resolve proxy. The given proxy host could not be resolved.^)
    UNRESOLVED_HOST = ExitCode.new(6,%q^Couldn't resolve host. The given remote host was not resolved.^)
    HOST_CONNECTION_FAILED = ExitCode.new(7,%q^Failed to connect to host.^)
    WEIRD_SERVER_REPLY = ExitCode.new(8,%q^Weird server reply. The server sent data curl couldn't parse.^)
    FTP_ACCESS_DENIED = ExitCode.new(9,%q^FTP access denied. The server denied login or denied access to the particular resource or directory you wanted to reach. Most often you tried to change to a directory that doesn't exist on the server.^)
    FTP_ACCEPT_FAILED = ExitCode.new(10,%q^FTP accept failed. While waiting for the server to connect back when an active FTP session is used, an error code was sent over the control connection or similar.^)
    FTP_WEIRD_PASS_REPLY = ExitCode.new(11,%q^FTP weird PASS reply. Curl couldn't parse the reply sent to the PASS request.^)
    FTP_TIMEOUT_EXPIRED = ExitCode.new(12,%q^During an active FTP session while waiting for the server to connect back to curl, the timeout expired.^)
    FTP_WEIRD_PASV_REPLY = ExitCode.new(13,%q^FTP weird PASV reply, Curl couldn't parse the reply sent to the PASV request.^)
    FTP_WEIRD_227_FORMAT = ExitCode.new(14,%q^FTP weird 227 format. Curl couldn't parse the 227-line the server sent.^)
    FTP_UNRESOLVED_227_HOST_IP = ExitCode.new(15,%q^FTP can't get host. Couldn't resolve the host IP we got in the 227-line.^)
    HTTP2_FRAMING_LAYER_ERROR = ExitCode.new(16,%q^HTTP/2 error. A problem was detected in the HTTP2 framing layer. This is somewhat generic and can be one out of several problems, see the error message for details.^)
    FTP_BINARY_TYPE_FAILED = ExitCode.new(17,%q^FTP couldn't set binary. Couldn't change transfer method to binary.^)
    PARTIAL_FILE = ExitCode.new(18,%q^Partial file. Only a part of the file was transferred.^)
    FTP_DOWNLOAD_FAILED = ExitCode.new(19,%q^FTP couldn't download/access the given file, the RETR (or similar) command failed.^)
    FTP_QUOTE_ERROR = ExitCode.new(21,%q^FTP quote error. A quote command returned error from the server.^)
    HTTP_PAGE_NOT_RETRIEVED = ExitCode.new(22,%q^HTTP page not retrieved. The requested url was not found or returned another error with the HTTP error code being 400 or above. This return code only appears if -f, --fail is used.^)
    WRITE_ERROR = ExitCode.new(23,%q^Write error. Curl couldn't write data to a local filesystem or similar.^)
    FTP_STOR_FILE_FAILED = ExitCode.new(25,%q^FTP couldn't STOR file. The server denied the STOR operation, used for FTP uploading.^)
    READ_ERROR = ExitCode.new(26,%q^Read error. Various reading problems.^)
    OUT_OF_MEMORY = ExitCode.new(27,%q^Out of memory. A memory allocation request failed.^)
    OPERATION_TIMEOUT = ExitCode.new(28,%q^Operation timeout. The specified time-out period was reached according to the conditions.^)
    FTP_PORT_FAILED = ExitCode.new(30,%q^FTP PORT failed. The PORT command failed. Not all FTP servers support the PORT command, try doing a transfer using PASV instead!^)
    FTP_REST_RESUME_FAILED = ExitCode.new(31,%q^FTP couldn't use REST. The REST command failed. This command is used for resumed FTP transfers.^)
    HTTP_RANGE_ERROR = ExitCode.new(33,%q^HTTP range error. The range "command" didn't work.^)
    HTTP_POST_ERROR = ExitCode.new(34,%q^HTTP post error. Internal post-request generation error.^)
    SSL_CONNECT_ERROR = ExitCode.new(35,%q^SSL connect error. The SSL handshaking failed.^)
    BAD_DOWNLOAD_RESUME = ExitCode.new(36,%q^Bad download resume. Couldn't continue an earlier aborted download.^)
    FILE_READ_FAILED = ExitCode.new(37,%q^FILE couldn't read file. Failed to open the file. Permissions?^)
    LDAP_BIND_FAILED = ExitCode.new(38,%q^LDAP cannot bind. LDAP bind operation failed.^)
    LDAP_SEARCH_FAILED = ExitCode.new(39,%q^LDAP search failed.^)
    LDAP_FUNCTION_NOT_FOUND = ExitCode.new(41,%q^Function not found. A required LDAP function was not found.^)
    CALLBACK_ABORT = ExitCode.new(42,%q^Aborted by callback. An application told curl to abort the operation.^)
    INTERNAL_ERROR = ExitCode.new(43,%q^Internal error. A function was called with a bad parameter.^)
    INTERFACE_ERROR = ExitCode.new(45,%q^Interface error. A specified outgoing interface could not be used.^)
    TOO_MANY_REDIRECTS = ExitCode.new(47,%q^Too many redirects. When following redirects, curl hit the maximum amount.^)
    UNKNOWN_OPTION = ExitCode.new(48,%q^Unknown option specified to libcurl. This indicates that you passed a weird option to curl that was passed on to libcurl and rejected. Read up in the manual!^)
    MALFORMED_TELNET_OPTION = ExitCode.new(49,%q^Malformed telnet option.^)
    SSL_BAD_PEER_CREDS = ExitCode.new(51,%q^The peer's SSL certificate or SSH MD5 fingerprint was not OK.^)
    SERVER_UNRESPONSIVE = ExitCode.new(52,%q^The server didn't reply anything, which here is considered an error.^)
    SSL_CRYPTO_ENGINE_NOT_FOUND = ExitCode.new(53,%q^SSL crypto engine not found.^)
    SSL_CRYPTO_ENGINE_NOT_DEFAULT = ExitCode.new(54,%q^Cannot set SSL crypto engine as default.^)
    NETWORK_DATA_SEND_FAILED = ExitCode.new(55,%q^Failed sending network data.^)
    NETWORK_DATA_RECEIVE_FAILED = ExitCode.new(56,%q^Failure in receiving network data.^)
    LOCAL_CERT_PROBLEM = ExitCode.new(58,%q^Problem with the local certificate.^)
    SSL_CIPHER_FAILED = ExitCode.new(59,%q^Couldn't use specified SSL cipher.^)
    PEER_AND_CA_CERTS_MISMATCH = ExitCode.new(60,%q^Peer certificate cannot be authenticated with known CA certificates.^)
    UNKNOWN_TRANSFER_ENCODING = ExitCode.new(61,%q^Unrecognized transfer encoding.^)
    INVALID_LDAP_URL = ExitCode.new(62,%q^Invalid LDAP URL.^)
    MAX_FILE_SIZE_EXCEEDED = ExitCode.new(63,%q^Maximum file size exceeded.^)
    FTP_SSL_LEVEL_FAILED = ExitCode.new(64,%q^Requested FTP SSL level failed.^)
    REWIND_FAILED = ExitCode.new(65,%q^Sending the data requires a rewind that failed.^)
    SSL_ENGINE_INIT_FAILED = ExitCode.new(66,%q^Failed to initialise SSL Engine.^)
    LOGIN_FAILED = ExitCode.new(67,%q^The user name, password, or similar was not accepted and curl failed to log in.^)
    TFTP_FILE_NOT_FOUND = ExitCode.new(68,%q^File not found on TFTP server.^)
    TFTP_PERMISSION_PROBLEM = ExitCode.new(69,%q^Permission problem on TFTP server.^)
    TFTP_OUT_OF_DISK_SPACE = ExitCode.new(70,%q^Out of disk space on TFTP server.^)
    TFTP_ILLEGAL_OPERATION = ExitCode.new(71,%q^Illegal TFTP operation.^)
    TFTP_UNKNOWN_TRANSFER_ID = ExitCode.new(72,%q^Unknown TFTP transfer ID.^)
    TFTP_FILE_EXISTS = ExitCode.new(73,%q^File already exists (TFTP).^)
    TFTP_UNKNOWN_USER = ExitCode.new(74,%q^No such user (TFTP).^)
    CHAR_CONVERSION_FAILED = ExitCode.new(75,%q^Character conversion failed.^)
    CHAR_CONVERSION_FUNCS_REQUIRED = ExitCode.new(76,%q^Character conversion functions required.^)
    SSL_CA_CERT_READ_PROBLEM = ExitCode.new(77,%q^Problem with reading the SSL CA cert (path? access rights?).^)
    URL_RESOURCE_DOES_NOT_EXIST = ExitCode.new(78,%q^The resource referenced in the URL does not exist.^)
    SSH_SESSION_UNKNOWN_ERROR = ExitCode.new(79,%q^An unspecified error occurred during the SSH session.^)
    SSL_CONNECTION_SHUTDOWN_FAILED = ExitCode.new(80,%q^Failed to shut down the SSL connection.^)
    CRL_FILE_LOAD_ERROR = ExitCode.new(82,%q^Could not load CRL file, missing or wrong format (added in 7.19.0).^)
    ISSUER_CHECK_FAILED = ExitCode.new(83,%q^Issuer check failed (added in 7.19.0).^)
    FTP_PRET_FAILED = ExitCode.new(84,%q^The FTP PRET command failed^)
    RTSP_CSEQ_NUMS_MISMATCH = ExitCode.new(85,%q^RTSP: mismatch of CSeq numbers^)
    RTSP_SESSION_IDS_MISMATCH = ExitCode.new(86,%q^RTSP: mismatch of Session Identifiers^)
    FTP_FILE_LIST_PARSE_FAILED = ExitCode.new(87,%q^unable to parse FTP file list^)
    FTP_CHUNK_CALLBACK_ERROR = ExitCode.new(88,%q^FTP chunk callback reported error^)
    NO_CONNECTION_AVAILABLE = ExitCode.new(89,%q^No connection available, the session will be queued^)
    SSL_AND_PINNED_PUBLIC_KEYS_MISMATCH = ExitCode.new(90,%q^SSL public key does not matched pinned public key^)
    
    @@cache = nil
    
    def self.get_all()
      if @@cache.nil?
        @@cache = {}
        
        constants.each do |name|
          c = const_get(name)
          @@cache[c.code] = c.descr
        end
      end
      
      return @@cache
    end
    
    def self.get_descr(code)
      return get_all()[code]
    end
    
    def self.get_name(code)
      constants.each do |name|
        c = const_get(name)
        
        if c.code == code
          return name.to_s
        end
      end
      
      return nil
    end
    
    ###
    # @param filename [String] file of copied and pasted exit codes from curl's manpage
    ###
    def self.puts_src_code(filename)
      lines = File.readlines(filename)
      
      code = nil
      is_code = true
      
      lines.each do |line|
        next if line =~ /\A\s*\n+\s*\z/
        
        line.chomp!
        
        if is_code
          code = line
        else
          puts "= ExitCode.new(#{code},%q^#{line}^)"
        end
        
        is_code = !is_code
      end
    end
  end
end
