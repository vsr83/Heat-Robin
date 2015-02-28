% READMESH Read a 2d-GMSH mesh from a .msh-file.
%
% M = READMESH(filename); reads a two-dimensional GMSH-file
% and creates corresponding data structure M.
%
% M.filename       the original filename of the mesh file
% M.num_nodes      number of nodes in the mesh.
% M.num_elements   number of elements in the mesh.
% M.num_lines      number of lines in the mesh
% M.num_triangles  number of triangles in the mesh
%
% M.nodes          M.num_nodes x 4 matrix describing the nodes with
%                  rows [node number, x, y, z];
% M.elements       M.num_elements x 1 cell-array of data structures 
%                  with fields describing type, tags and nodes of 
%                  each element.
% M.lines          M.num_lines x 1 matrix with indices to each line
%                  in M.elements.
% M.triangles      M.num_triangles x 1 matrix with indices to each
%                  triangle in M.elements.


function M= readmesh(filename)
    M.filename = filename;
    
    % Before further processing,  read the essential contents of the 
    % mesh file.
    
    fid = fopen(filename, 'r');
    format= readfield(fid);
    nodes = readfield(fid);
    elements = readfield(fid);    
    fclose(fid);

    % Read Nodes into a nx4 matrix with rows
    % [node number, x, y, z].
    M.num_nodes = str2num(nodes.lines{1});
    M.num_lines = 0;
    M.num_triangles = 0;
    
    M.nodes = zeros(M.num_nodes, 4);
    if M.num_nodes ~= nodes.linenum-1
        error 'Number of nodes in the mesh mismatch!';
    end
    for ind_node = 1:nodes.linenum-1
      M.nodes(ind_node, 1:4) = str2num(nodes.lines{ind_node+1});
    end
    
    % Read Elements such as lines and triangles.
    % .msh-file describes elements as rows
    % [number, type, number of tags, tag1, ..., node1, ..],
    % where type=1 corresponds to lines and 2 to triangles.
    
    M.num_elements = str2num(elements.lines{1});
    M.elements = cell(M.num_elements,1);
    if M.num_elements ~= elements.linenum-1
        error 'Number of elements in the mesh mismatch!';
    end
    
    for ind_elem = 1:elements.linenum-1
        element= str2num(elements.lines{ind_elem+1});
        
        elem.items = element;
        elem.nitems = length(element);
        
        elem.number = element(1);
        elem.type   = element(2);
        elem.ntags  = element(3);
        
        switch elem.type
            case 1
                M.num_lines = M.num_lines + 1;
            case 2
                M.num_triangles = M.num_triangles + 1;
            case 8
                M.num_lines = M.num_lines + 1;
            case 9
                M.num_triangles = M.num_triangles + 1;
            otherwise
                error 'Unknown element type!'
        end

        % Tags consist of following parameters:
        % 1. The physical entity to which element belongs
        % 2. The elementary geometrical entity to which ..
        % 3. The number of mesh partitions, to which the element belongs.
        % 4- The partition id's

        for ind_tag = 1:elem.ntags
            elem.tags(ind_tag) = element(3+ind_tag);
        end
        elem.physical = elem.tags(1);
        elem.geometrical = elem.tags(2);
        
        elem.nnodes = elem.nitems-3-elem.ntags;
        for ind_nodes = 1:elem.nnodes;
            elem.nodes(ind_nodes) = element(3+elem.ntags+ind_nodes);
        end
        M.elements{ind_elem} = elem;
    end
    
    
    % Extract lines from the elements

    M.lines = zeros(M.num_lines, 1);
    ind_line = 0;

    for ind_elem = 1:M.num_elements
        if M.elements{ind_elem}.type == 1 || M.elements{ind_elem}.type == 8
            ind_line = ind_line + 1;
            M.lines(ind_line) = ind_elem;
        end
    end

    % Extract triangles from the elements
    M.triangles = zeros(M.num_triangles, 1);
    M.elemtri = zeros(M.num_elements, 1);

    ind_triangle = 0;
    for ind_elem = 1:M.num_elements
        if M.elements{ind_elem}.type == 2 || M.elements{ind_elem}.type == 9
          ind_triangle = ind_triangle + 1;
            M.triangles(ind_triangle) = ind_elem;
            M.elemtri(ind_elem) = ind_triangle;
	    
     	    P = M.nodes(M.elements{ind_elem}.nodes, 2:3);
	    x1 = P(1, 1); x2 = P(2, 1); x3 = P(3, 1);
            y1 = P(1, 2); y2 = P(2, 2); y3 = P(3, 2);

            M.elements{ind_elem}.grad = [0 1 0; 0 0 1] * ...
                                        inv([1 x1 y1; 1 x2 y2; 1 x3 y3]);
            M.elements{ind_elem}.Je = [x2-x1, x3-x1; y2-y1, y3-y1];
            M.elements{ind_elem}.Jm = 1;%[1 0;0 1];
            M.elements{ind_elem}.vel = 0;
            M.elements{ind_elem}.area = polygon_area(P);
        end
    end    
    
    M.trianglepoints = zeros(M.num_triangles, 7);
    M.trianglephys = zeros(M.num_triangles, 1);
    for ind_tri = 1:M.num_triangles
      ind_elem = M.triangles(ind_tri);
      triangle = M.elements{ind_elem};
  
      M.trianglepoints(ind_tri, 1) = ind_elem;
      M.trianglepoints(ind_tri, 2:3) = M.nodes(triangle.nodes(1), 2:3);
      M.trianglepoints(ind_tri, 4:5) = M.nodes(triangle.nodes(2), 2:3);
      M.trianglepoints(ind_tri, 6:7) = M.nodes(triangle.nodes(3), 2:3);
			
      M.trianglephys(ind_tri) = triangle.physical;
    end
    M.trianglepointsx = sortrows(M.trianglepoints, 2);
    M.trianglepointsy = sortrows(M.trianglepoints, 3);
    
    M.minx = min(M.nodes(:, 2));
    M.maxx = max(M.nodes(:, 2));

    M.nodetri  = cell(M.num_nodes, 1);
    M.nodephys = cell(M.num_nodes, 1);
    for ind_node = 1:M.num_nodes
      M.nodetri{ind_node} = [];
      M.nodephys{ind_node} = [];
    end
    clear M.physnode;
    
    for ind_tri = 1:M.num_triangles
      tri = M.elements{M.triangles(ind_tri)};
      for ind_node = 1:length(tri.nodes)
      	node = tri.nodes(ind_node);
      	  M.nodetri{node}  = unique([M.nodetri{node} ind_tri]);
      	  M.nodephys{node} = unique([M.nodephys{node} tri.physical]);
          M.physnode{tri.physical}(node) = 1;
      end
    end
    
    for ind_line = 1:M.num_lines
      line = M.elements{M.lines(ind_line)};
      for ind_node = 1:length(line.nodes)
      	node = line.nodes(ind_node);
      	  M.nodephys{node} = unique([M.nodephys{node} line.physical]);
      end
    end
    
    M.nodeorder = zeros(M.num_nodes, 1);
    for ind_node = 1:M.num_nodes
      tri = M.elements{M.triangles(M.nodetri{ind_node}(1))};
      trinode = find(tri.nodes == ind_node);
      if trinode < 4
        M.nodeorder(ind_node) = 1;
      else
        M.nodeorder(ind_node) = 2;
      end
    end
    
    M.phystriangle = cell(max(M.trianglephys), 1);
    physlist = unique(M.trianglephys);
    for ind_phys = 1:length(physlist)
        phys = physlist(ind_phys);
        M.phystriangle{phys} = find(M.trianglephys == phys);
    end
end

% READFIELD Read a field from GetDP- or Gmsh-file.
%
% F = readfield(fid); reads a field from file identified fid into
% data structure F.
%
% F.name     contains the name of the field
% F.linenum  contains the number of lines of the data in the field.
% F.lines    contains the data of the field.
%
function F= readfield(fid)
    F.name = readline(fid);
    F.linenum = 0;
    while ~feof(fid)
        s = fgets(fid);
        if s(1) == '$'
            break;
        else
            F.linenum = F.linenum+1;
            F.lines{F.linenum} = s;
        end
    end
    s= sprintf('Read field %s with %d lines', F.name, F.linenum);
  %  disp(s);
end

% Remove '\n'-character from the end of a string
function s = readline(fid)
    s = fgets(fid);
    s = s(1:(length(s)-1));
end

function A = polygon_area(P)

[nVertices, tmp] = size(P);

u = P(:, 1) + [P(2:nVertices, 1);P(1, 1)];
v = [P(2:nVertices, 2);P(1, 2)] - P(:, 2);

A = abs(0.5*u'*v);

end