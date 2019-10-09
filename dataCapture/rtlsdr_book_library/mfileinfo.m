function mfileinfo(mfilein)
%MFILEINFO Generate and display file information webpage (identical to the 
% one the 'File Informataion' Simulink block makes)

file.name = mfilein;

% check file exists
if ~exist(file.name)
    error('Cannot locate the specified file');
    return
end

% if java is installed and the help browser can be launched
if usejava('swing')
    
    try

        %% IMPORT FILE PARAMS

        % find rtlsdr book root folder
        root = which('rtlsdr_book_library');
        root = root(1:end-length('rtlsdr_book_library/rtlsdr_book_library.slx'));
        
        % find filename, path etc
        file.path = which(file.name);
        [parentfolder,filenamenoext,fileext] = fileparts(file.path);
        file.relativepath = ['...',file.path(length(root):end)];
        file.name =[filenamenoext,fileext];
        
        % load file information cell array
        load('fileinfo.mat');
        
        % search to find file information
        row = find(ismember(fileinfo,file.name));
        
        % get remaining file information
        file.title = char(fileinfo(row,2));
        file.author = char(fileinfo(row,3));
        file.date = char(fileinfo(row,4));
        file.pdfnameddest = char(fileinfo(row,5));
        file.videourl = char(fileinfo(row,6));
        file.info1 = char(fileinfo(row,7));
        file.info2 = char(fileinfo(row,8));
        file.infoi = char(fileinfo(row,9));
        
        
        %% CREATE PARAMS FOR HTML
        % image hyperlinks
        imagepath_book = [root,'rtlsdr_book_library/block_icons/icon__book.png'];
        imagepath_desktopSDR = [root,'rtlsdr_book_library/block_icons/icon__desktopSDR.png'];
        imagepath_video = [root,'rtlsdr_book_library/block_icons/icon__video.png'];
        
    
        %% CREATE HTML WEBPAGE
        % create table at the top
        html = ['text://<html>',...
                '<title>',file.title,'</title>',...
                '<body>',...
                '<table style="width:100%" border=0 cellspacing=0 cellpadding=20">',...
                    '<tr>',...
                        '<td bgcolor="#007193" style="width: 100%;">',...
                        '<center><a href=http://www.desktopSDR.com>',...
                            '<img src="',imagepath_desktopSDR,'" title="Go to desktopSDR.com"  align="middle"/>',...
                        '</a></center>',...
                        '</td>',...
                    '</tr>',...
                '</table></br></br>',...
                '<table style="width:100%">',...
                    '<tr>',...
                        '<td class="expand"><font color="#323232" face="verdana"><h2>M-File Title:</h2></td>',...
                        '<td><font color="#323232" face="verdana"><h2>',file.title,'</h2></td>',...
                    '</tr>',...
                    '<tr>'...
                        '<td class="expand"><font color="#323232" face="verdana"><h3>M-File Filepath:</h3></td>',...
                        '<td><font color="#323232" face="verdana"><h3>',file.relativepath,'</h3></td>',...
                    '</tr>'...
                    '<tr>'...
                        '<td class="expand"><font color="#323232" face="verdana"><h5>M-File Author:</h5></td>',...
                        '<td><font color="#323232" face="verdana"><h5>',file.author,'</h5></td>',...
                    '</tr>'...
                    '<tr>'...
                        '<td class="expand"><font color="#323232" face="verdana"><h5>M-File Date:</h5></td>',...
                        '<td><font color="#323232" face="verdana"><h5>',file.date,'</h5></td>',...
                    '</tr>'...
                    '<tr>'...
                        '<td><font color="#323232" face="verdana"><h5>Exercise introduction:</h5></td>',...
                    '</tr>'...
                '</table>'];
        % add info paragraphs if they are populated
        if file.info1 ~= ''''
            html = [html,'<font color="#757575" face="verdana"><p align="justify">',file.info1,'</p>'];
        end
        if file.info2 ~= ''''
            html = [html,'<font color="#757575" face="verdana"><p align="justify">',file.info2,'</p>'];
        end
        if file.infoi ~= ''''
            html = [html,'<p align="justify"><i>',file.infoi,'</i></p>'];
        end
        % add hyperlinks in second table (book only if no video is provided)
        html = [html,'</br></br>',...
               '<table style="width:100%">',...
               '<tr>',...
                    '<td align="center">',...  COL 1 ROW 1
                        '<a href="matlab:openpdfnameddest_mfile(''',file.pdfnameddest,''')" STYLE="text-decoration: none">',...
                        '<img src="',imagepath_book,'" title="Click here to open the book at the corresponding exercise"  align="middle"/></a>',...
                    '</td>'];
        if file.videourl ~= ''''
            html = [html,...
                    '<td align="center">',...  COL 2 ROW 1
                        '<a href="',file.videourl,'" STYLE="text-decoration: none">',...
                        '<img src="',imagepath_video,'" title="Click here to watch the video"  align="middle"/></a>',...
                    '</td>'];
        end
        html = [html,'</tr>'];
         
        html = [html,...
                '<tr>',...
                    '<td align="center" rowspan="2">',... COL 1 ROW 2
                        '<a href="matlab:openpdfnameddest_mfile(''',file.pdfnameddest,''')" STYLE="text-decoration: none; color: #007193">',...
                        '<h4></br>Click here to open the book</br>at the corresponding exercise</h4></a>',...
                    '</td>'];            
        if file.videourl ~= ''''
            html = [html,...
                    '<td align="center">',... COL 2 ROW 2
                        '<a href="',file.videourl,'" STYLE="text-decoration: none; color: #007193">',...
                        '<h4></br>Click here to watch the video</h4></a>',...
                    '</td>',...
                '</tr>'];
        else
            html = [html,... ROW 2
                '</tr>'];
        end

        % finish table
        html = [html,'</table>'];
        
        % legal information
        html = [html,...
                '<font color="#757575" face="verdana" size=1></br></br></br></br></br></br>',...
                '</br><strong>Software, Simulation Examples and Design Exercises Licence Agreement</strong>',...
                '</br><p align="justify">This license agreement refers to the simulation examples, design exercises and files, and associated software MATLAB and Simulink resources that accompany the book:',...
                '</br></br>&nbsp;&nbsp;&nbsp;<em>Title: Software Defined Radio using MATLAB & Simulink and the RTL-SDR',...
                '</br>&nbsp;&nbsp;&nbsp;Published by Strathclyde Academic Media, 2015',...
                '</br>&nbsp;&nbsp;&nbsp;Authored by Robert W. Stewart, Kenneth W. Barlee, Dale S.W. Atkinson, and Louise H. Crockett</em>',...
                '</br></br><p align="justify">and made available as a download from <a href="http://www.desktopSDR.com" STYLE="text-decoration: none">www.desktopSDR.com</a> or variously acquired by other means such as via USB storage, cloud storage, disk or any other electronic or optical or magnetic storage mechanism. These files and associated software may be used subject to the terms of agreement of the conditions below:',...
                '</br></br>&nbsp;&nbsp;&nbsp;<em>Copyright © 2015 Robert W. Stewart, Kenneth W. Barlee, Dale S.W. Atkinson, and Louise H. Crockett. All rights reserved.</em>',...
                '</br></br><p align="justify">Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:',...
                '<ol type="1">',...
                '</br><li>Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.</li>',...
                '</br><li>Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.</li>',...
                '</br><li>Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.</li>',...
                '</br><li>In all cases, the software is, and all modifications and derivatives of the software shall be, licensed to you solely for use in conjunction with The MathWorks, Inc. products and service offerings.</li>',...
                '</ol>',...
                '</br><p align="justify">THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.</p>',...
                '</br><strong>Audio Tracks used in Simulations Examples and Design Exercises</strong>',...
                '<p align="justify">The music and vocal files used within the Examples files and software within the book were variously written, arranged, performed, recorded and produced by Garrey Rice, Adam Struth, Jamie Struth, Iain Thistlethwaite and also Marshall Craigmyle who collectively, and individually where appropriate, assert and retain all of their copyright, performance and artistic rights. Permission to use and reproduce this music is granted for all purposes associated with MATLAB and Simulink software and the simulation examples and design exercises files that accompany this book. Requests to use the music for any other purpose should be directed to:  info@desktopSDR.com. For information on music track names, full credits, and links to the musicians please refer to <a href="http://www.desktopSDR.com/more/audio" STYLE="text-decoration: none">www.desktopSDR.com/more/audio</a>.</p></br></br>'];

        % finish HTML code
        html = [html,...
                '</font></body>',...
                '</html>'];
            
        %% LOAD WEBPAGE
        web(html);

    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Software, Simulation Examples and Design Exercises Licence Agreement  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         
%  This license agreement refers to the simulation examples, design
%  exercises and files, and associated software MATLAB and Simulink
%  resources that accompany the book:
% 
%    Title: Software Defined Radio using MATLAB & Simulink and the RTL-SDR 
%    Published by Strathclyde Academic Media, 2015
%    Authored by Robert W. Stewart, Kenneth W. Barlee, Dale S.W. Atkinson, 
%    and Louise H. Crockett
%
%  and made available as a download from www.desktopSDR.com or variously 
%  acquired by other means such as via USB storage, cloud storage, disk or 
%  any other electronic or optical or magnetic storage mechanism. These 
%  files and associated software may be used subject to the terms of 
%  agreement of the conditions below:
%
%    Copyright © 2015 Robert W. Stewart, Kenneth W. Barlee, 
%    Dale S.W. Atkinson, and Louise H. Crockett. All rights reserved.
%
%  Redistribution and use in source and binary forms, with or without 
%  modification, are permitted provided that the following conditions are
%  met:
%
%   (1) Redistributions of source code must retain the above copyright 
%       notice, this list of conditions and the following disclaimer.
%
%   (2) Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in 
%       the documentation and/or other materials provided with the 
%       distribution.
%
%   (3) Neither the name of the copyright holder nor the names of its 
%       contributors may be used to endorse or promote products derived 
%       from this software without specific prior written permission.
%
%   (4) In all cases, the software is, and all modifications and 
%       derivatives of the software shall be, licensed to you solely for
%       use in conjunction with The MathWorks, Inc. products and service
%       offerings.
%
%  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
%  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
%  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR 
%  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
%  HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
%  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
%  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
%  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY 
%  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
%  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
%  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%
%%  Audio Tracks used in Simulations Examples and Design Exercises
% 
%  The music and vocal files used within the Examples files and software 
%  within the book were variously written, arranged, performed, recorded 
%  and produced by Garrey Rice, Adam Struth, Jamie Struth, Iain 
%  Thistlethwaite and also Marshall Craigmyle who collectively, and 
%  individually where appropriate, assert and retain all of their 
%  copyright, performance and artistic rights. Permission to use and 
%  reproduce this music is granted for all purposes associated with 
%  MATLAB and Simulink software and the simulation examples and design 
%  exercises files that accompany this book. Requests to use the music 
%  for any other purpose should be directed to: info@desktopSDR.com. For
%  information on music track names, full credits, and links to the 
%  musicians please refer to www.desktopSDR.com/more/audio.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%