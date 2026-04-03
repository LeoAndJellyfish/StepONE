import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../models/achievement.dart';
import '../models/category.dart';
import '../models/tag.dart';
import '../services/achievement_dao.dart';
import '../services/category_dao.dart';
import '../services/tag_dao.dart';
import '../theme/app_theme.dart';

class AchievementFormPage extends StatefulWidget {
  final Achievement? achievement;

  const AchievementFormPage({super.key, this.achievement});

  @override
  State<AchievementFormPage> createState() => _AchievementFormPageState();
}

class _AchievementFormPageState extends State<AchievementFormPage> {
  final _formKey = GlobalKey<FormState>();
  final AchievementDao _achievementDao = AchievementDao();
  final CategoryDao _categoryDao = CategoryDao();
  final TagDao _tagDao = TagDao();
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _organizationController;
  late TextEditingController _remarksController;
  
  List<Category> _categories = [];
  List<Tag> _allTags = [];
  List<Tag> _selectedTags = [];
  Category? _selectedCategory;
  DateTime _achievementDate = DateTime.now();
  bool _isCollective = false;
  bool _isLeader = false;
  int? _participantCount;
  
  bool _isLoading = true;
  bool get _isEditing => widget.achievement != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.achievement?.title ?? '');
    _descriptionController = TextEditingController(text: widget.achievement?.description ?? '');
    _organizationController = TextEditingController(text: widget.achievement?.organization ?? '');
    _remarksController = TextEditingController(text: widget.achievement?.remarks ?? '');
    
    if (widget.achievement != null) {
      _achievementDate = widget.achievement!.achievementDate;
      _isCollective = widget.achievement!.isCollective;
      _isLeader = widget.achievement!.isLeader;
      _participantCount = widget.achievement!.participantCount;
    }
    
    _loadData();
  }

  Future<void> _loadData() async {
    final categories = await _categoryDao.getAll();
    final tags = await _tagDao.getAll();
    
    List<Tag> selectedTags = [];
    if (widget.achievement != null && widget.achievement!.id != null) {
      selectedTags = await _tagDao.getTagsForAchievement(widget.achievement!.id!);
    }
    
    setState(() {
      _categories = categories;
      _allTags = tags;
      _selectedTags = selectedTags;
      if (widget.achievement != null) {
        _selectedCategory = categories.firstWhere(
          (c) => c.id == widget.achievement!.categoryId,
          orElse: () => categories.first,
        );
      } else if (categories.isNotEmpty) {
        _selectedCategory = categories.first;
      }
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _organizationController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _saveAchievement() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择成就分类')),
      );
      return;
    }

    final now = DateTime.now();
    final achievement = Achievement(
      id: widget.achievement?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      categoryId: _selectedCategory!.id!,
      achievementDate: _achievementDate,
      organization: _organizationController.text.trim().isEmpty 
          ? null 
          : _organizationController.text.trim(),
      isCollective: _isCollective,
      isLeader: _isLeader,
      participantCount: _participantCount,
      remarks: _remarksController.text.trim().isEmpty 
          ? null 
          : _remarksController.text.trim(),
      createdAt: widget.achievement?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      int achievementId;
      if (_isEditing) {
        await _achievementDao.update(achievement);
        achievementId = widget.achievement!.id!;
      } else {
        achievementId = await _achievementDao.insert(achievement);
      }
      
      final existingTags = await _tagDao.getTagsForAchievement(achievementId);
      for (final tag in existingTags) {
        if (tag.id != null) {
          await _tagDao.removeTagFromAchievement(achievementId, tag.id!);
        }
      }
      
      for (final tag in _selectedTags) {
        if (tag.id != null) {
          await _tagDao.addTagToAchievement(achievementId, tag.id!);
        }
      }
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? '成就已更新' : '成就已创建'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败：$e')),
      );
    }
  }

  Future<void> _deleteAchievement() async {
    if (widget.achievement?.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除成就'),
        content: Text('确定要删除成就 "${widget.achievement?.title}" 吗？\n此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _achievementDao.delete(widget.achievement!.id!);
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('成就已删除')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败：$e')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _achievementDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() => _achievementDate = picked);
    }
  }

  Future<void> _showTagSelector() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _TagSelectorSheet(
        allTags: _allTags,
        selectedTags: _selectedTags,
        onTagsSelected: (tags) {
          setState(() => _selectedTags = tags);
        },
        tagDao: _tagDao,
        onTagCreated: _reloadTags,
      ),
    );
  }

  Future<void> _reloadTags() async {
    final tags = await _tagDao.getAll();
    setState(() {
      _allTags = tags;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景图片
          Positioned.fill(
            child: Image.asset(
              'assets/images/zzSQs.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // 第一层毛玻璃效果（轻微模糊）
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.15),
                      Colors.black.withOpacity(0.25),
                      Colors.black.withOpacity(0.4),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),
          // 第二层毛玻璃效果（极轻微模糊，增强层次感）
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
              child: Container(
                color: Colors.black.withOpacity(0.1),
              ),
            ),
          ),
          // 内容区域
          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white70))
                : CustomScrollView(
                    slivers: [
                      // 标题栏
                      SliverAppBar(
                        floating: true,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        title: Text(
                          _isEditing ? '编辑成就' : '新建成就',
                          style: const TextStyle(color: Colors.white),
                        ),
                        actions: [
                          if (_isEditing)
                            TextButton(
                              onPressed: _deleteAchievement,
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              child: const Text('删除'),
                            ),
                          TextButton(
                            onPressed: _saveAchievement,
                            style: TextButton.styleFrom(foregroundColor: Colors.white),
                            child: const Text('保存'),
                          ),
                        ],
                      ),
                      // 表单内容
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverToBoxAdapter(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionCard('基本信息', [
                                  _buildTextField(
                                    controller: _titleController,
                                    label: '成就名称 *',
                                    hint: '例如：全国大学生数学建模竞赛一等奖',
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return '请输入成就名称';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: _descriptionController,
                                    label: '详细描述',
                                    hint: '描述这个成就的详细信息',
                                    maxLines: 3,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildCategorySelector(),
                                  const SizedBox(height: 16),
                                  _buildTagSelector(),
                                ]),
                                const SizedBox(height: 16),
                                _buildSectionCard('时间和组织', [
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      '获得日期',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 13,
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        DateFormat('yyyy 年 M 月 d 日').format(_achievementDate),
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.calendar_today, color: Colors.white70),
                                      onPressed: _selectDate,
                                    ),
                                    onTap: _selectDate,
                                  ),
                                  const SizedBox(height: 8),
                                  _buildTextField(
                                    controller: _organizationController,
                                    label: '颁发组织',
                                    hint: '例如：教育部、学校',
                                  ),
                                ]),
                                const SizedBox(height: 16),
                                _buildSectionCard('团队信息', [
                                  SwitchListTile(
                                    title: Text(
                                      '团队成就',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 14,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '是否为团队参与的成就',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 12,
                                      ),
                                    ),
                                    value: _isCollective,
                                    onChanged: (value) {
                                      setState(() => _isCollective = value);
                                    },
                                    activeColor: AppTheme.primaryColor,
                                  ),
                                  if (_isCollective) ...[
                                    const SizedBox(height: 8),
                                    SwitchListTile(
                                      title: Text(
                                        '我是负责人',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 14,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '是否为团队负责人',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.5),
                                          fontSize: 12,
                                        ),
                                      ),
                                      value: _isLeader,
                                      onChanged: (value) {
                                        setState(() => _isLeader = value);
                                      },
                                      activeColor: AppTheme.primaryColor,
                                    ),
                                    const SizedBox(height: 12),
                                    DropdownButtonFormField<int>(
                                      value: _participantCount,
                                      decoration: InputDecoration(
                                        labelText: '参与人数',
                                        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: Colors.white, width: 1.5),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.08),
                                      ),
                                      dropdownColor: Colors.black87,
                                      items: [
                                        const DropdownMenuItem(value: null, child: Text('选择人数', style: TextStyle(color: Colors.white70))),
                                        ...List.generate(49, (i) => i + 2).map((count) {
                                          return DropdownMenuItem(
                                            value: count,
                                            child: Text('$count 人', style: const TextStyle(color: Colors.white)),
                                          );
                                        }),
                                      ],
                                      onChanged: (value) {
                                        setState(() => _participantCount = value);
                                      },
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ]),
                                const SizedBox(height: 16),
                                _buildSectionCard('其他信息', [
                                  _buildTextField(
                                    controller: _remarksController,
                                    label: '备注',
                                    hint: '其他需要说明的信息',
                                    maxLines: 3,
                                  ),
                                ]),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.95),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int? maxLines,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines ?? 1,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.12),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return DropdownButtonFormField<Category>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: '成就分类 *',
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.12),
      ),
      dropdownColor: Colors.black87,
      items: _categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category.name, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedCategory = value);
      },
      validator: (value) {
        if (value == null) {
          return '请选择成就分类';
        }
        return null;
      },
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildTagSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _showTagSelector,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Text(
                  '标签',
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
                const Spacer(),
                const Icon(Icons.add_circle_outline, color: Colors.white70, size: 20),
              ],
            ),
          ),
        ),
        if (_selectedTags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedTags.map((tag) {
              return Chip(
                label: Text(tag.name, style: const TextStyle(color: Colors.white, fontSize: 12)),
                backgroundColor: Colors.white.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                onDeleted: () {
                  setState(() {
                    _selectedTags.remove(tag);
                  });
                },
                deleteIconColor: Colors.white70,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class _TagSelectorSheet extends StatefulWidget {
  final List<Tag> allTags;
  final List<Tag> selectedTags;
  final Function(List<Tag>) onTagsSelected;
  final TagDao tagDao;
  final VoidCallback? onTagCreated;

  const _TagSelectorSheet({
    required this.allTags,
    required this.selectedTags,
    required this.onTagsSelected,
    required this.tagDao,
    this.onTagCreated,
  });

  @override
  State<_TagSelectorSheet> createState() => _TagSelectorSheetState();
}

class _TagSelectorSheetState extends State<_TagSelectorSheet> {
  late List<Tag> _tempSelectedTags;
  final TextEditingController _newTagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tempSelectedTags = List.from(widget.selectedTags);
  }

  @override
  void dispose() {
    _newTagController.dispose();
    super.dispose();
  }

  Future<void> _createNewTag() async {
    final tagName = _newTagController.text.trim();
    if (tagName.isEmpty) return;

    final code = tagName.toUpperCase().replaceAll(' ', '_');
    final now = DateTime.now();
    
    final newTag = Tag(
      name: tagName,
      code: code,
      createdAt: now,
    );

    final id = await widget.tagDao.insert(newTag);
    final createdTag = newTag.copyWith(id: id);
    
    setState(() {
      _tempSelectedTags.add(createdTag);
    });
    
    widget.onTagsSelected(_tempSelectedTags);
    widget.onTagCreated?.call();
    
    _newTagController.clear();
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('标签 "$tagName" 已创建并选中')),
    );
  }

  Future<void> _deleteTag(Tag tag) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除标签'),
        content: Text('确定要删除标签 "${tag.name}" 吗？\n该操作将移除所有成就与此标签的关联。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && tag.id != null) {
      await widget.tagDao.delete(tag.id!);
      
      setState(() {
        _tempSelectedTags.removeWhere((t) => t.id == tag.id);
      });
      
      widget.onTagsSelected(_tempSelectedTags);
      widget.onTagCreated?.call();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('标签 "${tag.name}" 已删除')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '选择标签',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  widget.onTagsSelected(_tempSelectedTags);
                  Navigator.pop(context);
                },
                child: const Text('确定'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _newTagController,
            decoration: InputDecoration(
              labelText: '创建新标签',
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: _createNewTag,
              ),
            ),
            onSubmitted: (_) => _createNewTag(),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Expanded(
            child: widget.allTags.isEmpty
                ? Center(
                    child: Text(
                      '暂无标签，请创建新标签',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    itemCount: widget.allTags.length,
                    itemBuilder: (context, index) {
                      final tag = widget.allTags[index];
                      final isSelected = _tempSelectedTags.any((t) => t.id == tag.id);
                      return ListTile(
                        title: Text(tag.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _deleteTag(tag),
                            ),
                            Checkbox(
                              value: isSelected,
                              onChanged: (selected) {
                                setState(() {
                                  if (selected ?? false) {
                                    _tempSelectedTags.add(tag);
                                  } else {
                                    _tempSelectedTags.removeWhere((t) => t.id == tag.id);
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _tempSelectedTags.removeWhere((t) => t.id == tag.id);
                            } else {
                              _tempSelectedTags.add(tag);
                            }
                          });
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
